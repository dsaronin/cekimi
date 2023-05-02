# 
# Verb class
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#   
# handles all things related to a verb

class Verb

  attr_accessor  :verb_infinitive, :verb_stem, :last_vowel, :final_cons
  attr_accessor  :a2_sfx, :a4_sfx, :k4_chg, :stem_syllables
  attr_accessor  :is_t_except, :is_e_except, :stem_end_vowel,:last_pure_vowel
  attr_accessor  :verb_stem_td

# constants
  TURK_VOWELS      = "aeiouıöü"
  TURK_VOWEL_REGEX = /[aeiouıöü]/  # all turkish vowels
  TURK_CONSONENT_REGEX = /[^aeiouıöü]/  # all turkish consonents
  T_MATCH = /t/    # matches a trailing t in stem
  D_VOICED  = "d"    # replaces a T with D before vowel-suffixes
  TURK_CHANGABLE_UNVOICED_CONSONENTS = /[fstkçşhp]/
  LEGAL_INFINITIVES = /\p{L}\p{L}+m[ae]k$/  # filter valid Türkçe fiiller
  STRIP_INFIN_SUFFIX = /m[ae]k$/  # strips off mak/mek from infinitive
  T_EXCEPTIONS = /^(gi)|(e)t$/  # special handling for Ts
  E_EXCEPTIONS = /^[yd]e$/   # special handling for Es

  #  -------------------------------------------------------------------
  #  instantiate by Verb.new( fiil )
  #  returns new obj or raises exception if invalid turkish verb
  #
  #  -------------------------------------------------------------------
  def initialize( fiil )

       # preliminary massage to lowercase and remove lead/trailing whitespace
    @verb_infinitive = (fiil || "").strip.downcase
       # unicode \p{L} = \w
    if @verb_infinitive.match  LEGAL_INFINITIVES 
      set_stem
      grammar_exceptions_check
      last_vowel_setup 
      last_consonent_setup 
    else
      raise ArgumentError, "#{fiil}: Türkçe bir fiil değildir."
    end
  end
  #  -------------------------------------------------------------------

  #  -------------------------------------------------------------------
  #  to_s  -- inspect object as a string
  #  -------------------------------------------------------------------
  def to_s
    return "verb: #{@verb_infinitive}, stem: -#{@verb_stem}/#{@verb_stem_td}" + 
           ", end_vwl?: #{@stem_end_vowel}, t_exc?: #{@is_t_except}, e_exc?: #{@is_e_except}" +
           "\nlast_pure_v: #{@last_pure_vowel}, last_v: #{@last_vowel}, f_cons: #{@final_cons}, n_syll: #{@stem_syllables}"
  end

  #  -------------------------------------------------------------------
  #  set_stem -- verb stem setup
  #  -------------------------------------------------------------------
  def set_stem
    @verb_stem = @verb_infinitive.gsub( STRIP_INFIN_SUFFIX , "" )
    @stem_syllables = @verb_stem.count TURK_VOWELS
  end

  #  -------------------------------------------------------------------
  #  grammar_exceptions_check -- check for verb exceptions
  #  -------------------------------------------------------------------

  def grammar_exceptions_check
    @is_t_except = @verb_stem.match( T_EXCEPTIONS ) ? true : false
    @is_e_except = @verb_stem.match( E_EXCEPTIONS ) ? true : false

       # prepare the alternate voiced stem if a T-exception verb
    @verb_stem_td =  ( @is_t_except ?  @verb_stem.chop + D_VOICED : @verb_stem )
  end

  #  -------------------------------------------------------------------
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

  #  -------------------------------------------------------------------
  # last_consonent_setup -- handles t/d trailing-consonent prep
  #  -------------------------------------------------------------------

  def last_consonent_setup 
    @final_cons = 
      ( !@is_t_except  &&  @verb_stem[-1].match( T_MATCH ) )  ?  D_VOICED  :  ""
  end

end   # class Verb
