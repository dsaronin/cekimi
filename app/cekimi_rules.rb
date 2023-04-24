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
  # parse_rule -- parses a rule & generates conjugation
  # args: 
  #   my_verb -- verb being conjugated
  #
  #  -----------------------------------------------------------------
  def parse_rule( my_verb )
    puts "starting parsing rule..."
    table_out = TableOut.new( my_verb, self)
  end

  #  ----------------------------------------------------------------
  #  to_s -- debuigging trace output for a CekimiRule object
  #  ----------------------------------------------------------------
  
  def to_s
    "#{@caption_eng}, #{@grammar_role},  #{@lexical_rule}, " + 
    "#{@rule_info}"

  end
  
  #  ----------------------------------------------------------------

 
end

