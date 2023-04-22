# 
# TableOut class
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#   
# collects & able to output a table of results
# a single conjugation table is typically conjugations for all
# six personal tenses (stored as a 2x3 array)
#
# TableOut
#   @my_verb : Verb Object being conjugated
#   @my_rule : CekimiRules object with precedence
#   @next_table : next table in a chain of conjugated tables; else nil
#   @chain : the output chain which the parser is currently building
#   @my_table : [2][3] array of conjugated strings
#               [S1][P1]   1st person sing | plural
#               [S2][P2]   2nd person sing | plural
#               [S3][P3]   3rd person sing | plural

  #  ----------------------------------------------------------------
  #  CONSTANTS
  #  ----------------------------------------------------------------
  SINGLR = 0  # selects singular side of table
  PLURAL = 1  # selects plural side of table
  P1 = 0      # selects 1st person
  P2 = 1      # selects 2nd person
  P3 = 2      # selects 3rd person

  # TURK2INDX will be keyed by conjugation rules
  # returns the correct indexes for accessing the output table
  TURK2INDX = {
    :ben   => [SINGLR,P1],
    :sen   => [SINGLR,P2],
    :o     => [SINGLR,P3],
    :biz   => [PLURAL,P1],
    :siz   => [PLURAL,P2],
    :onlar => [PLURAL,P3]
  }

class TableOut

  #  ----------------------------------------------------------------
  #  get_table_index
  #  returns a [x,y] array for accessing the correct person in table
  #  ----------------------------------------------------------------
  def TableOut.get_table_index( key )
    return TURK2INDEX[key]
  end

  #  ----------------------------------------------------------------
  #  new -- creates and initializes a TableOut object
  #  ----------------------------------------------------------------
  def initialize(my_verb,my_rule)
    @my_verb = my_verb
    @my_rule = my_rule
    @chain = ""
    @my_table = Array.new(2){ Array.new(3) }
  end

end  # class TableOut

