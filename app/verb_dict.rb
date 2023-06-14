# 
# VerbDict class
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#   
# handles all things related to the Turk-English Dictionary
# dictionary is a stripped down subset of the fatashi turkce_dictionary.txt
# three fields per records: turkish entry, english def, examples
# there can be multiple entries with same spelling
# fields are delimited by tab
#

class VerbDict
  include Singleton

  FIELD_DELIMITER = /\t/
  DICTFILE = "app/turk_verbs.txt"

  ENTRY = 0   # field index for key entry
  DEF   = 1   # field index for english definition
  EX    = 2   # field index for examples
  
  #  ------------------------------------------------------------
  #  load_dictionary  -- loads verb database and creates dictionary
  #  ------------------------------------------------------------
  def VerbDict.load_dictionary(file)
    Environ.log_info "Loading verb dictionary..."
    File.open(file, "r") do |f|
      while n = f.gets
        fields = n.split( FIELD_DELIMITER )
        key = fields[ ENTRY ]
        @@verbs[key] ||= []
        @@verbs[key] <<= fields[ DEF ] 
      end  # while reading each line in file
    end  # file read
    Environ.log_info "Verb dictionary has #{@@verbs.length} entries."
  end

  #  ------------------------------------------------------------
  #  get_english  -- returns the english definition for a key
  #  returns array of definitions, [""] if not defined
  #  ------------------------------------------------------------
  def VerbDict.get_english(key)
    return ( @@verbs[ key ] || [""] )
  end

  #  ------------------------------------------------------------
  #  dictionary setup; executed first time singleton initialized
  #  ------------------------------------------------------------
  @@verbs = {}     # initialize internal dictionary
  VerbDict.load_dictionary(DICTFILE)

  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
end  # class verbdict

