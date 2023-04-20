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
  TURK_CONSONENT_REGEX = /[^aeiouıöü]/  # all turkish consonents
  TURK_CHANGABLE_VOICED_CONSONENTS = /[kptç]/
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
      last_vowel_setup 
      last_consonent_setup 
    else
      raise ArgumentError, "#{fiil}: Türkçe bir fiil değildir."
    end
  end
#-------------------------------------------------------------------

  def to_s
    return "verb: #{@verb_infinitive}, stem: -#{@verb_stem}, sfx: #{@suffix_chain}" + 
           ", is_t_exc?: #{@is_t_except}, is_e_exc?: #{@is_e_except}"  +
           "\nstem_end_vwl?: #{@stem_end_vowel}, last_v: #{@last_vowel}, last_pure_v: #{@last_pure_vowel}"
  end

#-------------------------------------------------------------------
# last_vowel_setup -- finds last vowel for vowel harmony
  # also groups together all the vowel checking logic
# side effects: 
#   @stem_end_vowel, @last_vowel, @last_pure_vowel
#-------------------------------------------------------------------
  def last_vowel_setup
    @stem_end_vowel = false   # assume stem doesn't end in vowel
    vs = @verb_stem.reverse   # reverse the stem to proc backwards

    if( idex = vs.index TURK_VOWEL_REGEX ) then
      @last_vowel = vs[ idex ]   # last vowel for normal harmony

      if idex == 0 then
        @stem_end_vowel = true
        # verb stem ended in a vowel; skip it to find the other vowel

        idex = vs.index( TURK_VOWEL_REGEX, 1 )
        idex = 0 if idex.nil?  # special case: yemek, demek
      end
      # certain conjugations want to know the last pure vowel
      # (ie not an end-of-stem vowel)
      @last_pure_vowel = vs[ idex ]

    else  # idex was nil!
      # ?? should never come here if original infinitive check correct
      raise IndexError, "couldn't find vowel in vowel stem"
    end
  end

#-------------------------------------------------------------------
# last_consonent_setup -- handles voiced/unvoiced consonent prep
#-------------------------------------------------------------------
  def last_consonent_setup 
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
