# 
# Çekimi conjugation rules objects
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#   
#

  require "prawn"
  require "prawn/measurement_extensions"

class GenPdf
  #  include Prawn::View

  attr_accessor  :my_pdf

  #  ------------------------------------------------------------
  #  CONSTANTS
  #  ------------------------------------------------------------

  PDF_EXT = ".pdf"

  PADDING = 2.mm

  HEADING_FONT_SIZE = 64
  DEF_FONT_SIZE = 14
  BOX_TITLE_FONT_SIZE = 11
  BOX_FONT_SIZE = 14

  GAP_VERTICAL = 1.cm
  TABLE_GAP_HORIZONTAL = 1.cm

  HEADING_POSITION = [0,25.cm]
  HEADING_HEIGHT = 25.mm
  BOX_HEIGHT = 32.mm
  BOX_WIDTH  = 9.cm


  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
  #  CLASS-LEVEL actions & methods
  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
  def initialize(verb)
    @my_pdf = Prawn::Document.new
    
    @my_pdf.stroke_axis

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
  #  -----------------------------------------------------------------
  def heading(verb,definition)
  end

  #  -----------------------------------------------------------------
  #  show_left_table  -- renders a left-hand table
  #  always moves down and starts at left
  #  -----------------------------------------------------------------
  def show_left_table(title, left_col, right_col)
  end

  #  -----------------------------------------------------------------
  #  show_right_table  -- renders a right-hand table
  #  always moves bounding box to right, leaping over left table
  #  -----------------------------------------------------------------
  def show_right_table(title, left_col, right_col)
  end

  #  -----------------------------------------------------------------
  #  fileout  -- outputs the pdf file
  #  -----------------------------------------------------------------
  def fileout()
    @my_pdf.render_file( @filename )
  end
 
end  # class GenPdf

