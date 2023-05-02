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
#   @next_table : next table in a stub of conjugated tables; else nil
#   @stub : the output stub which the parser is currently building
#   @my_table : [2][3] array of conjugated strings
#               [S1][P1]   1st person sing | plural
#               [S2][P2]   2nd person sing | plural
#               [S3][P3]   3rd person sing | plural

  #  ----------------------------------------------------------------
  #  CONSTANTS
  #  ----------------------------------------------------------------
  MIN_CELL_WIDTH  = 3  # minimum char width of output cell in table 
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

  attr_accessor  :my_verb, :my_rule, :stub, :my_table, :last_vowel
  attr_accessor  :cell_width, :empty

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
    @last_vowel = my_verb.last_vowel  # initialize stub's 1st last vwl

    @stub = ""
    @cell_width = MIN_CELL_WIDTH   # size of output cell width in chars

    @my_table = Array.new(2){ Array.new(3) }
    @empty = true    # will be false if table has anything in it
  end

  #  ----------------------------------------------------------------
  #  conjugate -- places completed stub into the table, per pronoun
  #  arg
  #    pronoun: turkish pronoun, as symbol
  #    :ben, :sen, :o, :biz, :siz, :onlar
  #  ----------------------------------------------------------------
  def conjugate( pronoun )
    (ix, iy) = TURK2INDX[ pronoun ]  # translates a pronoun into x,y
    @my_table[ix][iy] = @stub  # grab the stub
       # reset cell width if we encounter a length longer 
    @cell_width = @stub.length if ( @stub.length > @cell_width )
    @empty = false
  end

  #  ----------------------------------------------------------------
  #  ----------------------------------------------------------------

  FORMAT_HEADER = "\n%s: \t%s  -->  %s"
  FORMAT_LINE   = "    %-Xs\t%-Xs"

  #  ----------------------------------------------------------------
  #  show_table  -- displays the conjugation table to console
  #  ----------------------------------------------------------------
  def show_table()

    str = sprintf( FORMAT_HEADER, @my_rule.caption_turk, @my_verb.verb_infinitive, @stub.downcase )
    puts Environ.wrapGreen str

    if !is_empty?
         # adjust format line to account for max cell of results
      cellformat = FORMAT_LINE.gsub( /X/, @cell_width.to_s )

         # for each person of each singular/plural, output a row
      (P1..P3).each do |iy|
        str = sprintf( cellformat, @my_table[SINGLR][iy].downcase, @my_table[PLURAL][iy].downcase )
        puts Environ.wrapYellow str
      end  # each do

    end  # if table not empty
  end

  #  ----------------------------------------------------------------
  #  is_empty?  -- returns true if table is empty
  #  ----------------------------------------------------------------
  def is_empty?
    return @empty
  end

  #  ----------------------------------------------------------------
  #  ----------------------------------------------------------------
end  # class TableOut
