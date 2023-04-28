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

  STEM_RULE_REGEX = /^~V/   # matches rule requesting verb stem
  INVOKE_RULE_REGEX = /^&(\d+)/  # matches recursive rule parse req
  OUTPUT_RULE_REGEX = /^Ω/  # table_out the result
  RULE_OP_REGEX = /^@([AYK])(\d)/ # matches rule requesting an operation
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
    raise NameError, "#{rule_key}: ÇekimiRule not found or undefined." 
  end

  #  -----------------------------------------------------------------
  # prep_and_parse -- preps for recursive descent parsing
  # args: 
  #   my_verb -- verb being conjugated
  #  -----------------------------------------------------------------
  def prep_and_parse( my_verb )
    Environ.log_debug( "starting parsing rule: #{@my_key}..." )
    @my_table_out = TableOut.new( my_verb, self)
    parse_rule( )   # begins parsing a rule
  end

  #  ----------------------------------------------------------------
  #  to_s -- debuigging trace output for a CekimiRule object
  #  ----------------------------------------------------------------
  
  def to_s
    "#{@caption_eng}, #{@grammar_role},  #{@lexical_rule}, " + 
    "#{@rule_info}"

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
          when STEM_RULE_REGEX  then  
            @my_table_out.chain = @my_table_out.my_verb.verb_stem
          when RULE_OP_REGEX  then  inplace_operation( $1, $2 )  
          when INVOKE_RULE_REGEX  then true # nop
          when OUTPUT_RULE_REGEX  then true # nop
          else
            Environ.log_warn( "Rule token not found: #{token}; ignored." )
          end  # case
      end  # foreach token
    end  # unless @lexical_rule nil
  end


  def inplace_operation(op_type, op_subtype)
    rule =  CekimiRules.get_rule( ":_@#{op_type}#{op_subtype}" )
  end

  
 
end

