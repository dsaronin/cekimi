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

  # initialize rules here if not already 
  @@cekimi_rules ||= YAML.unsafe_load_file( "app/rules.yml" )

  def CekimiRules.cekimi_rules_count
    return @@cekimi_rules.size
  end

  def CekimiRules.cekimi_rules
    return @@cekimi_rules
  end

  def CekimiRules.get_rule( rule_key )
    return @@cekimi_rules[ rule_key ]
  end

  #  -----------------------------------------------------------------
  # prep_and_parse -- preps for recursive descent parsing
  # args: 
  #   my_verb -- verb being conjugated
  # returns:
  #   table_out object with result
  #  -----------------------------------------------------------------
  def prep_and_parse( my_verb )
    puts "starting parsing rule..."
    table_out = TableOut.new( my_verb, self)
    parse_rule( table_out )   # begins parsing a rule
    return table_out
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
  #  args:
  #    table_out  -- TableOut object for generating the conjugation
  #  ----------------------------------------------------------------
  def parse_rule( table_out )
    idex = 0
    while idex < @lexical_rule.length   begin 
      token = @lexical_rule[idex++]  # 'pop' token
      case token
      when /^~V/ : table_out.chain = table_out.my_verb.verb_stem
      when /^(@\w+)/ : get_rule(
    end
  end

 
end

