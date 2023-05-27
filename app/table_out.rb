# 
# TableOut class
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#   
# collects & able to output a table of results
# a single conjugation table is typically conjugations for all
# six personal tenses (stored as a 2x3 array)
#
# TableOut
#   @verb_infinitive : Verb infinitive being conjugated
#   @next_table : next table in a stub of conjugated tables; else nil
#   @stub : the output stub which the parser is currently building
#   @my_table : [2][3] array of conjugated strings
#               [S1][P1]   1st person sing | plural
#               [S2][P2]   2nd person sing | plural
#               [S3][P3]   3rd person sing | plural

  require_relative "gen_pdf"

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

  attr_accessor  :verb_infinitive, :stub, :my_table, :last_vowel
  attr_accessor  :cell_width, :empty, :my_pair
  attr_accessor  :caption_eng, :caption_turk, :grammar_role, :is_neg

  #  ----------------------------------------------------------------
  #  get_table_index
  #  returns a [x,y] array for accessing the correct person in table
  #  ----------------------------------------------------------------
  def TableOut.get_table_index( key )
    return TURK2INDEX[key]
  end

  #  ----------------------------------------------------------------
  #  new -- creates and initializes a TableOut object
  #  args:
  #    caption_eng, caption_turk, grammar_role, is_neg  from rule obj
  #  ----------------------------------------------------------------
  def initialize(my_verb, caption_eng, caption_turk, grammar_role, is_neg)
    @verb_infinitive = my_verb.verb_infinitive
    @caption_eng = caption_eng
    @caption_turk = caption_turk
    @grammar_role = grammar_role
    @is_neg = is_neg
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

  FORMAT_HEADER = "\n%s:"
  # DEPRECATED: FORMAT_HEADER = "\n%s: %s --> %s"
  FORMAT_LINE   = "    %-Xs\t%-Xs"

  #  ----------------------------------------------------------------
  #  show_table  -- displays the conjugation table to console
  #  args:
  #    pair_tables -- true if output pair of neg/poz tables
  #  ----------------------------------------------------------------
  def show_table( pair_tables )

    if pair_tables && @my_pair && !@my_pair.is_empty?
    then
      show_paired_tables
    else

      str = sprintf( FORMAT_HEADER, caption_turk )
      puts Environ.wrapCyanBold str

      if !is_empty?
           # adjust format line to account for max cell of results
        cellformat = FORMAT_LINE.gsub( /X/, @cell_width.to_s )

           # for each person of each singular/plural, output a row
        (P1..P3).each do |iy|
          str = sprintf( cellformat, @my_table[SINGLR][iy].downcase, @my_table[PLURAL][iy].downcase )
          puts Environ.wrapYellow str
        end  # each do

      end  # if table not empty
    end  # paired tables

    pdf_output
  end

  def pdf_output()
    r = GenPdf.new( @verb_infinitive )
    r.heading(@verb_infinitive.capitalize)
    top_edge = r.show_left_table("geniş zaman", "giderim\ngidersin\ngider", "gideriz\ngidersiniz\ngiderler")
    top_edge = r.show_right_table( top_edge, "olumsuz genis zaman", "giderim\ngidersin\ngider", "gideriz\ngidersiniz\ngiderler" )
    r.fileout()
  end

  #  ----------------------------------------------------------------
  #  ----------------------------------------------------------------

  PAIRED_FORMAT_HEADER = "\n%s:\t\t\t\t%s:"
  # DEPRECATED: PAIRED_FORMAT_HEADER = "\n%s: %s --> %s\t%s: %s --> %s"
  PAIRED_FORMAT_LINE   = "    %-Xs\t%-Xs\t\t    %-Zs\t%-Zs"

  #  ----------------------------------------------------------------
  #  show_paired_tables  -- displays a pair of related tables
  #  assumes my_pair not nil and valid table
  #  ----------------------------------------------------------------
  def show_paired_tables()
    str = sprintf( PAIRED_FORMAT_HEADER, caption_turk, @my_pair.caption_turk )
    puts Environ.wrapCyanBold str

    if !is_empty?
         # adjust format line to account for max cell of results
      cellformat = PAIRED_FORMAT_LINE.gsub( /X/, @cell_width.to_s ).gsub( /Z/, @my_pair.cell_width.to_s )

         # for each person of each singular/plural, output a row
      (P1..P3).each do |iy|
        str = sprintf( 
              cellformat, 
              @my_table[SINGLR][iy].downcase, @my_table[PLURAL][iy].downcase,
              @my_pair.my_table[SINGLR][iy].downcase, @my_pair.my_table[PLURAL][iy].downcase 
        )
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
  #  pair_tables
  #  arg:
  #    table_out object to be paired
  #  NOTE: pairs both tables together
  #  ----------------------------------------------------------------
  def pair_tables( paired_table )
    @my_pair = paired_table
    paired_table.my_pair = self
  end

  #  ----------------------------------------------------------------
  #  ----------------------------------------------------------------
end  # class TableOut

