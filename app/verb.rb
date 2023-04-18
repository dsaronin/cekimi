# 
# Verb class
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#   
# handles all things related to a verb

class Verb

  attr_accessor  :verb_infinitive, :verb_stem, :last_vowel, :final_cons
  attr_accessor  :a2_sfx, :a4_sfx, :k4_chg

  # instantiate by Verb.new( fiil )
  # returns new obj or raises exception if invalid turkish verb
  #
  def initialize( fiil )
       # preliminary massage to lowercase and remove lead/trailing whitespace
    verb_infinitive = (fiil || "").strip.downcase
    if verb_infinitive.match /\w\w?m[ae]k$/
      verb_stem = verb_infinitive.gsub( /m[ae]k$/, "" )
      # last_vowel =
      # final_cons =
    else
      raise ArgumentError, "#{fiil}: Türkçe bir fiil değildir."
    end
  end

end   # class Verb
