# 
# Çekimi conjugation rules objects
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#   
#

  require "yaml"
  require_relative "table_out"

class CekimiRules
  attr_accessor :caption_eng, :caption_turk, :gen_method, :grammar_role, :lexical_rule
  attr_accessor :parent_conj, :child_conj, :next_list, :rule_info, :exceptions
  attr_accessor :my_key

  #  ------------------------------------------------------------
  #  CONSTANTS
  #  ------------------------------------------------------------

  TRACE_GEN  = true  # to trace the transformation each token

  # inplace_operation REGEX for op switch
  VOWEL_HARMONY   =  /A/    # 4way/2way vowel harmony op
  BUFFER_VOWEL    =  /Y/    # add Y buffer for double vowel op
  DROP_VOWEL      =  /X/    # drop vowel-stem final vowel op
  CONS_TRANSFORM  =  /K/    # unvoiced > voiced consonent transform op

  # parse_rule REGEX for token switch
  STEM_RULE_REGEX   = /^~V/   # matches rule requesting verb stem
  INVOKE_RULE_REGEX = /^&(\w+)/  # matches recursive rule parse req
  OUTPUT_RULE_REGEX = /^Ω/  # table_out the result
  ATOM_TOKEN_REGEX  = /\p{L}+/  # matches any alpha
  RULE_OP_REGEX     = /^@([AYK])(\d)/ # matches rule requesting an operation
      # side effect of matching: 
      #   $1 will be the op request
      #   $2 will be the sub-type of the op request
      # ex: @A4 -- request 4-way vowel harmony
      # ex: @Y  -- request vowel-vowel buffering

  

  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
  #  ------------------------------------------------------------

  # initialize rules here if not already 
  @@cekimi_rules ||= YAML.unsafe_load_file( "app/rules.yml" )

  def CekimiRules.cekimi_rules_count
    return @@cekimi_rules.size
  end

  def CekimiRules.cekimi_rules
    return @@cekimi_rules
  end

  def CekimiRules.get_rule( rule_key )
    Environ.log_debug( "searching for rule: #{rule_key}" )
    rule = @@cekimi_rules[ rule_key ]
    return rule unless rule.nil?
    raise ArgumentError, "#{rule_key}: ÇekimiRule not found or undefined." 
  end

  #  -----------------------------------------------------------------
  # prep_and_parse -- preps for recursive descent parsing
  # args: 
  #   my_verb -- verb being conjugated
  # returns:
  #   @my_table_out: formed result for output
  #  -----------------------------------------------------------------
  def prep_and_parse( my_verb )
    Environ.log_debug( "starting parsing rule: #{@my_key}..." )
    @my_table_out = TableOut.new( my_verb, self)
    parse_rule( )   # begins parsing a rule
    return @my_table_out 
  end

  #  ----------------------------------------------------------------
  #  to_s -- debuigging trace output for a CekimiRule object
  #  ----------------------------------------------------------------
  
  def to_s
    "#{@caption_eng}, #{@grammar_role},  #{@lexical_rule}, " + 
    "#{@rule_info}"
  end

  #  ----------------------------------------------------------------
  #  ----------------------------------------------------------------
  #  ----------------------------------------------------------------
  
  def gen( str )
    @my_table_out.chain << str 
    puts "gen: #{@my_table_out.chain}"  if TRACE_GEN
  end

  
  #  ----------------------------------------------------------------
  #  parse_rule -- parses a rule & generates conjugation
  #  recursive-descent parser
  #  output of parser is in the table_out.chain field
  #  assumption:
  #    @my_table_out  -- TableOut object for generating the conjugation
  #  ----------------------------------------------------------------
  def parse_rule( )
    unless @lexical_rule.nil? then
      @lexical_rule.each   do |token|
        case token
          when INVOKE_RULE_REGEX  then true # nop
          when STEM_RULE_REGEX  then  gen @my_table_out.my_verb.verb_stem
          when RULE_OP_REGEX  then  inplace_operation( $1, $2 )  
          when ATOM_TOKEN_REGEX  then  gen token
          when OUTPUT_RULE_REGEX  then true # nop
          else
            Environ.log_warn( "Rule token not found: #{token}; ignored." )
          end  # case
      end  # foreach token
    end  # unless @lexical_rule nil
  end


  #  ----------------------------------------------------------------
  #  inplace_operation -- handles an in-place alpha transformation
  #  args:
  #    op_type -- string for the type of inplace operation: A,K,X,Y
  #    op_subtype  -- [optional]: digit to indicate subtype
  #  ----------------------------------------------------------------
  def inplace_operation(op_type, op_subtype)
    rule =  CekimiRules.get_rule( "_@#{op_type}#{op_subtype}".to_sym )
    case op_type
      when VOWEL_HARMONY   then  op_vowel_harmony( rule )
      when BUFFER_VOWEL    then  op_buffer_vowel( rule )
      when CONS_TRANSFORM  then  op_cons_transform( rule )
      when DROP_VOWEL      then  op_drop_stem_vowel( rule )
      else
        Environ.log_warn( "in-place operation not found: #{token}; ignored." )
    end   #  case
  end

  #  ----------------------------------------------------------------
  #  op_vowel_harmony  -- does vowel harmony with last seen vowel
  #  arg: rule  [might be nil in future]
  #  ----------------------------------------------------------------
  def op_vowel_harmony( rule )
      # lookup corresponding harmony
    lookup = @my_table_out.last_vowel.to_sym
    vwl = rule.rule_info[ lookup ]
    if vwl then  # vowel harmony was found; use it
      gen vwl    # push to output queue
      @my_table_out.last_vowel = vwl   # becomes new last vowel
    else  # error: expected harmony not found
        Environ.log_warn( "vowel harmony key not found: #{lookup}; ignored." )
    end  # if.then.else check that harmony match found
  end

  #  ----------------------------------------------------------------
  #  op_buffer_vowel  -- adds buffer for vowel if last in chain
  #  arg: rule  [might be nil in future]
  #  ----------------------------------------------------------------
  def op_buffer_vowel( rule )
    if @my_table_out.chain[-1] =~ TURK_VOWEL_REGEX
      gen "Y"   # push buffer to queue
    end

  end

  #  ----------------------------------------------------------------
  #  op_cons_transform
  #  arg: rule  [might be nil in future]
  #  ----------------------------------------------------------------
  def op_cons_transform( rule )
  end

  #  ----------------------------------------------------------------
  #  op_drop_stem_vowel  -- drops a verb stem vowel
  #  arg: rule  [might be nil in future]
  #  ----------------------------------------------------------------
  def op_drop_stem_vowel( rule )
    if @my_table_out.my_verb.stem_end_vowel then
      @my_table_out.last_vowel = @my_table_out.my_verb.last_pure_vowel
      @my_table_out.chain.chomp
    end
  end

  #  ----------------------------------------------------------------
  #  ----------------------------------------------------------------
 
end  #class CekimiRules

