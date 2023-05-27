# 
# Çekimi conjugation rules objects
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#   
#

  require "prawn"
  require "prawn/measurement_extensions"

class GenPdf
  #  include Prawn::View

  attr_accessor  :pdf

  #  ------------------------------------------------------------
  #  CONSTANTS
  #  ------------------------------------------------------------

  PDF_EXT = ".pdf"

  DEF_FONT_SIZE = 14

  BOX_TITLE_FONT_SIZE = 11
  BOX_FONT_SIZE = 16
  BOX_TITLE_PADDING = 2.mm
  BOX_HEIGHT = 32.mm
  BOX_WIDTH  = 9.cm
  BOX_GAP_HORIZONTAL = 1.cm
  BOX_GAP_VERTICAL = 1.cm

  INNER_INDENT = 10.mm
  INNER_WIDTH  = 4.cm
  INNER_HEIGHT = 25.mm

  HEADING_POSITION = [0,25.cm]
  HEADING_HEIGHT = 3.cm
  HEADING_WIDTH = 19.cm
  HEADING_PADDING = 5.mm
  HEADING_FONT_SIZE = 76

  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
  #  CLASS-LEVEL actions & methods
  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
  def initialize(verb)
    @pdf = Prawn::Document.new
    
    #  @pdf.stroke_axis

    @verb = verb.capitalize
    @filename = verb.downcase + PDF_EXT
  end

  #  -----------------------------------------------------------------
  #  -----------------------------------------------------------------
  #  -----------------------------------------------------------------
  #  -----------------------------------------------------------------
  #  -----------------------------------------------------------------

 
  #  -----------------------------------------------------------------
  #  -----------------------------------------------------------------
  #  INSTANCE METHODS
  #  -----------------------------------------------------------------
  #  -----------------------------------------------------------------


  #  -----------------------------------------------------------------
  #  heading -- renders the heading with verb and possible definition
  #  verb,definition
  #  -----------------------------------------------------------------
  def heading()
    @pdf.bounding_box( 
        HEADING_POSITION, 
        height: HEADING_HEIGHT,
        width: HEADING_WIDTH
    ) do
      @pdf.font_size HEADING_FONT_SIZE 
      @pdf.pad( HEADING_PADDING ) {
        @pdf.text( @verb, style: 'bold' )
      }
      #  @pdf.transparent( 0.4 ) { @pdf.stroke_bounds }
    end  # bounding box block
  end

  #  -----------------------------------------------------------------
  #  show_left_table  -- renders a left-hand table
  #  always moves down and starts at left
  #  title, left_col, right_col
  #  -----------------------------------------------------------------
  def show_left_table()
    @pdf.move_down BOX_GAP_VERTICAL

    outer_top = @pdf.cursor

    @pdf.bounding_box(
      [0, outer_top],
      width: BOX_WIDTH,
      height: BOX_HEIGHT
    ) do
      @pdf.transparent( 0.3 ) { @pdf.stroke_bounds }
      @pdf.font_size BOX_TITLE_FONT_SIZE 
      @pdf.pad( BOX_TITLE_PADDING ) {
        @pdf.text( "genis zaman", indent_paragraphs: BOX_TITLE_PADDING )
      }

      inner_top = @pdf.cursor  # remember inner columns top pt

      # left column
      @pdf.bounding_box( 
          [INNER_INDENT,inner_top], 
          width: INNER_WIDTH, 
          height: INNER_HEIGHT 
      ) do
        @pdf.font_size BOX_FONT_SIZE
        @pdf.text("giderim\ngidersin\ngider", style: 'bold')
      end

      # right column
      @pdf.bounding_box( 
          [INNER_INDENT+INNER_WIDTH,inner_top], 
          width: INNER_WIDTH, 
          height: INNER_HEIGHT 
      ) do
        @pdf.font_size BOX_FONT_SIZE
        @pdf.text("gideriz\ngidersiniz\ngiderler", style: 'bold')
      end


    end  # table bounding box
    
    return outer_top   # remember top edge if paired tables
  end

  #  -----------------------------------------------------------------
  #  show_right_table  -- renders a right-hand table
  #  always moves bounding box to right, leaping over left table
  #  title, left_col, right_col
  #  -----------------------------------------------------------------
  def show_right_table( top_edge )

    @pdf.bounding_box(
      [BOX_WIDTH + BOX_GAP_HORIZONTAL, top_edge ],
      width: BOX_WIDTH,
      height: BOX_HEIGHT
    ) do
      @pdf.transparent( 0.3 ) { @pdf.stroke_bounds }
      @pdf.font_size BOX_TITLE_FONT_SIZE 
      @pdf.pad( BOX_TITLE_PADDING ) {
        @pdf.text( "olumsuz genis zaman", indent_paragraphs: BOX_TITLE_PADDING )
      }

      inner_top = @pdf.cursor  # remember inner columns top pt

      # left column
      @pdf.bounding_box( 
          [INNER_INDENT,inner_top], 
          width: INNER_WIDTH, 
          height: INNER_HEIGHT 
      ) do
        @pdf.font_size BOX_FONT_SIZE
        @pdf.text("giderim\ngidersin\ngider", style: 'bold')
      end

      # right column
      @pdf.bounding_box( 
          [INNER_INDENT+INNER_WIDTH,inner_top], 
          width: INNER_WIDTH, 
          height: INNER_HEIGHT 
      ) do
        @pdf.font_size BOX_FONT_SIZE
        @pdf.text("gideriz\ngidersiniz\ngiderler", style: 'bold')
      end


    end  # table bounding box
    
    return top_edge   # remember top edge if paired tables
   end

  #  -----------------------------------------------------------------
  #  fileout  -- outputs the pdf file
  #  -----------------------------------------------------------------
  def fileout()
    @pdf.render_file( @filename )
  end
 
end  # class GenPdf

