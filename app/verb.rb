# 
# Verb class
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#   
# handles all things related to a verb

class Verb

  attr_accessor  :verb_infinitive, :verb_stem, :last_vowel, :final_cons
  attr_accessor  :a2_sfx, :a4_sfx, :k4_chg

# constants
  TURK_VOWEL_REGEX = /[aeiouıöü]/


  # instantiate by Verb.new( fiil )
  # returns new obj or raises exception if invalid turkish verb
  #
  def initialize( fiil )
       # preliminary massage to lowercase and remove lead/trailing whitespace
    @verb_infinitive = (fiil || "").strip.downcase
       # unicode \p{L} = \w
    if @verb_infinitive.match /\p{L}\p{L}+m[ae]k$/
      @verb_stem = @verb_infinitive.gsub( /m[ae]k$/, "" )
      # last_vowel =
      # final_cons =
    else
      raise ArgumentError, "#{fiil}: Türkçe bir fiil değildir."
    end
  end

  def to_s
    return "verb: #{@verb_infinitive}, stem: -#{@verb_stem}" 
  end

end   # class Verb
