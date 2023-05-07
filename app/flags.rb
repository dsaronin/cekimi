# Çekimi: Türkçe Fiil Çekimi
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#
# class Flags -- maintains cekimi trace, logging, execution flags
#

class Flags

  #  ------------------------------------------------------------
  #  flags default initial settings
  #
  TRACE_GEN       = false # to trace the transformation each token
  TRACE_VERB      = false # to trace verb parameter breakdown
  NEGPOZ_PAIR     = true  # conjugate positive-negative pairs
  CONJUGATE_CHAIN = true  # repeatedly conjugate chain of rules
  FULL_RULE_LIST  = false # true if list ALL cekimi rules
  LOG_LEVEL_QUIET    = Logger::WARN 
  LOG_LEVEL_VERBOSE  = Logger::DEBUG 

  #  ------------------------------------------------------------
  #  flag names (keys into hash)
  #
  FLAG_GEN_TRACE         = "g"
  FLAG_VERB_TRACE        = "v"
  FLAG_CHAIN_CONJUGATE   = "c"
  FLAG_PAIR_CONJUGATE    = "p"
  FLAG_FULL_RULE         = "f"
  FLAG_LOG_LEVEL         = "z"

  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
  #  ------------------------------------------------------------

  #  ------------------------------------------------------------
  #  new  -- creates a new object with the flags hash set to defaults
  #  ------------------------------------------------------------
  def initialize()
    @flags = {
      FLAG_GEN_TRACE         =>  TRACE_GEN,
      FLAG_VERB_TRACE        =>  TRACE_VERB,
      FLAG_CHAIN_CONJUGATE   =>  CONJUGATE_CHAIN,
      FLAG_PAIR_CONJUGATE    =>  NEGPOZ_PAIR,
      FLAG_FULL_RULE         =>  FULL_RULE_LIST,
      FLAG_LOG_LEVEL         =>  LOG_LEVEL_QUIET
    }
  end

  #  ------------------------------------------------------------
  #  to_s -- converts flags to a display string
  #  ------------------------------------------------------------
  def to_s
    str = ""
    @flags.each do |flag, setting|
      str <<= sprintf( "%1s - %1s, ", flag, setting )
    end
    return str
  end

  def  to_help
    return  "" + 
      FLAG_GEN_TRACE + "--gen trace, "  +
      FLAG_VERB_TRACE + "--verb trace, "  +
      FLAG_CHAIN_CONJUGATE + "--conjugate chain, "  +
      FLAG_PAIR_CONJUGATE + "--pair poz/neg conjugate, "  +
      FLAG_FULL_RULE + "--full list of rules, "  +
      FLAG_LOG_LEVEL + "--verbose/quiet logging"
  end

  #  ------------------------------------------------------------
  #  ------------------------------------------------------------

end   # flags
