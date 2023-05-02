# 
# Çekimi conjugation rules objects
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#   
#

  require "yaml"
  require_relative "table_out"

class CekimiRules
  attr_accessor :caption_eng, :caption_turk, :grammar_role, :lexical_rule
  attr_accessor :parent_conj, :child_conj, :next_list, :rule_info, :exceptions
  attr_accessor :my_key, :my_table_out

  #  ------------------------------------------------------------
  #  CONSTANTS
  #  ------------------------------------------------------------

  TRACE_GEN  = false  # to trace the transformation each token
  LAST_VOWEL_REGEX = /[aeiouıöü][bcçdfgğhjklmnprsştvyz]*$/i
  VOICED_CONSONANTS   = /[bcdgğjlmnrvyz]/i
  UNVOICED_CONSONANTS = /[çfhkpsşt]/i

  D_CONS_REGEX   = /[aeiouıöübcdgğjlmnrvyz]/i
  T_CONS_REGEX   = /[çfhkpsşt]/i
  K_CONS_REGEX   = /k$/i
  D_CONS_SUFFIX  = "D" 
  T_CONS_SUFFIX  = "T"
  G_CONS_SUFFIX  = "Ğ"

  # inplace_operation REGEX for op switch
  VOWEL_HARMONY   =  /A/    # 4way/2way vowel harmony op
  BUFFER_VOWEL    =  /Y/    # add Y buffer for double vowel op
  DROP_VOWEL      =  /X/    # drop vowel-stem final vowel op
  CONS_TRANSFORM  =  /K/    # unvoiced > voiced consonent transform op
  TD_TRANSFORM    =  /D/    # suffix changes depending stub consonant type
  KG_TRANSFORM    =  /G/    # suffix changes when K before vowel

  # parse_rule REGEX for token switch
  STEM_RULE_REGEX   = /^~V/   # matches rule requesting verb stem
  TD_STEM_RULE_REGEX   = /^~W/   # matches rule requesting voiced verb stem
  INVOKE_RULE_REGEX = /^&(\w+)/  # matches recursive rule parse req
  OUTPUT_RULE_REGEX = /^Ω/  # table_out the result  (DEPRECATED)
  ATOM_TOKEN_REGEX  = /\p{L}+/  # matches any alpha
  RULE_OP_REGEX     = /^@([AYKXDG])(\d)?/ # matches rule requesting an operation
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
  #  gen  -- append a suffix to the stub
  #  ----------------------------------------------------------------
  def gen( str )
    @my_table_out.stub << str   # append to stub

    # check for the last vowel and remember it
    if( idex = str.index LAST_VOWEL_REGEX ) then
      @my_table_out.last_vowel = str[idex].downcase   # becomes new last vowel
    end 
 
    puts "gen: #{@my_table_out.stub}"  if TRACE_GEN
  end

  
  #  ----------------------------------------------------------------
  #  parse_rule -- parses a rule & generates conjugation
  #  recursive-descent parser
  #  output of parser is in the table_out.stub field
  #  assumption:
  #    @my_table_out  -- TableOut object for generating the conjugation
  #  ----------------------------------------------------------------
  def parse_rule( )
    unless @lexical_rule.nil? then
      @lexical_rule.each  do  |token|
        case token
          when INVOKE_RULE_REGEX  then  table_generation( $1 )
          when STEM_RULE_REGEX    then  gen @my_table_out.my_verb.verb_stem
          when TD_STEM_RULE_REGEX then  gen @my_table_out.my_verb.verb_stem_td
          when RULE_OP_REGEX      then  inplace_operation( $1, $2 )  
          when ATOM_TOKEN_REGEX   then  gen token
          when OUTPUT_RULE_REGEX  then  true  # nop
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
      when TD_TRANSFORM    then  op_td_transform( rule )
      when KG_TRANSFORM    then  op_kg_transform( rule )
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
  #  op_buffer_vowel  -- adds buffer for vowel if last in stub
  #  arg: rule  [might be nil in future]
  #  ----------------------------------------------------------------
  def op_buffer_vowel( rule )
    if @my_table_out.stub[-1] =~ Verb::TURK_VOWEL_REGEX
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
  #  op_td_transform  -- does the TD suffix transformation
  #  arg: rule  [might be nil in future]
  #  ----------------------------------------------------------------
  def op_td_transform( rule )
    if @my_table_out.stub[-1] =~ D_CONS_REGEX then
      gen D_CONS_SUFFIX
    else
      gen T_CONS_SUFFIX
    end

  end


  #  ----------------------------------------------------------------
  #  op_kg_transform  -- does the KĞ stem transformation
  #  arg: rule  [might be nil in future]
  #  ----------------------------------------------------------------
  def op_kg_transform( rule )
    if @my_table_out.stub[-1] =~ K_CONS_REGEX  then
      @my_table_out.stub.chop!   # remove the trailing K
      gen G_CONS_SUFFIX 
    end
  end


  #  ----------------------------------------------------------------
  #  op_drop_stem_vowel  -- drops a verb stem vowel
  #  arg: rule  [might be nil in future]
  #  ----------------------------------------------------------------
  def op_drop_stem_vowel( rule )
    if @my_table_out.my_verb.stem_end_vowel then
      @my_table_out.last_vowel = @my_table_out.my_verb.last_pure_vowel
      @my_table_out.stub.chop!   # remove the trailing vowl
    end
  end

  #  ----------------------------------------------------------------
  #  table_generation  -- generates a table of conjugations for
  #    all six personal cases
  #  ----------------------------------------------------------------
 
  def table_generation( rulekey )

    rule =  CekimiRules.get_rule( rulekey.to_sym )
    rule.my_table_out = @my_table_out

    restore_stub = String.new( @my_table_out.stub )  # remember stub
    stub_len = restore_stub.length
    # 
    # TODO? do we need to remember last_vowel also??
    #
    rule.rule_info.each do |pronoun, lexrule|
      rule.lexical_rule = lexrule
      rule.parse_rule  # parse a rule for person
      @my_table_out.conjugate(pronoun)
      @my_table_out.stub = restore_stub[0,stub_len]  # reset the stub

    end  # do each hash

  end

  #  ----------------------------------------------------------------
  #  ----------------------------------------------------------------
 
end  #class CekimiRules

