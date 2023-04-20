# 
# Verb class
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#   
# handles all things related to a verb

class Verb

  attr_accessor  :verb_infinitive, :verb_stem, :last_vowel, :final_cons
  attr_accessor  :a2_sfx, :a4_sfx, :k4_chg, :suffix_chain
  attr_accessor  :is_t_except, :is_e_except

# constants
  TURK_VOWEL_REGEX = /[aeiouıöü]/  # all turkish vowels
  LEGAL_INFINITIVES = /\p{L}\p{L}+m[ae]k$/  # filter valid Türkçe fiiller
  STRIP_INFIN_SUFFIX = /m[ae]k$/  # strips off mak/mek from infinitive
  T_EXCEPTIONS = /^(gi)|(e)t$/  # special handling for Ts
  E_EXCEPTIONS = /^[yd]e$/   # special handling for Es

#-------------------------------------------------------------------
  # instantiate by Verb.new( fiil )
  # returns new obj or raises exception if invalid turkish verb
  #
#-------------------------------------------------------------------
  def initialize( fiil )
       # preliminary massage to lowercase and remove lead/trailing whitespace
    @verb_infinitive = (fiil || "").strip.downcase
       # unicode \p{L} = \w
    if @verb_infinitive.match  LEGAL_INFINITIVES 
      @verb_stem = @verb_infinitive.gsub( STRIP_INFIN_SUFFIX , "" )
      @suffix_chain = ""  # make suffix chain empty
      @is_t_except = @verb_stem.match( T_EXCEPTIONS ) ? true : false
      @is_e_except = @verb_stem.match( E_EXCEPTIONS ) ? true : false
      # last_vowel =
      # final_cons =
    else
      raise ArgumentError, "#{fiil}: Türkçe bir fiil değildir."
    end
  end
#-------------------------------------------------------------------

  def to_s
    return "verb: #{@verb_infinitive}, stem: -#{@verb_stem}, sfx: #{@suffix_chain}" + 
           ", is_t_exc?: #{@is_t_except}, is_e_exc?: #{@is_e_except}" 
  end

#-------------------------------------------------------------------
  # parse_rule -- parses a rule & generates conjugation
  # args: rule -- object of CekimiRules
  #
#-------------------------------------------------------------------
  def parse_rule( rule )
  end
#-------------------------------------------------------------------

end   # class Verb
