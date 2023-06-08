# 
# Çekimi conjugation rules objects
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#   
#

  require "prawn"
  require "prawn/measurement_extensions"

class GenPdf

  attr_accessor  :accum

  #  ------------------------------------------------------------
  #  CONSTANTS
  #  ------------------------------------------------------------

  PDF_EXT = ".pdf"

  DEF_FONT_SIZE = 14

  BOX_TITLE_FONT_SIZE = 10
  BOX_FONT_SIZE = 14
  BOX_MIN_FONT  =  8
  BOX_TITLE_PADDING = 1.mm
  BOX_HEIGHT = 35.mm
  BOX_WIDTH  = 92.mm
  BOX_GAP_HORIZONTAL = 1.cm
  BOX_GAP_VERTICAL = 5.mm
  
  BOX_TRANSPARENCY = 0.2

  INNER_INDENT = 5.mm
  INNER_WIDTH  = 43.mm
  INNER_HEIGHT = 25.mm

  HEADING_POSITION = [0,25.cm]
  HEADING_HEIGHT = 35.mm
  HEADING_WIDTH = 19.cm
  HEADING_PADDING = 5.mm
  HEADING_FONT_SIZE = 64

  FONT_PALATINO = "$HOME/.local/share/fonts/Linotype\ GmbH/TrueType/Palatino\ Linotype"
  FONT_TAHOMA   = "$HOME/.local/share/fonts/Microsoft\ Corporation/TrueType/Tahoma"
  FONT_ARIAL    = "$HOME/.local/share/fonts/Monotype\ Imaging/TrueType/Arial"
  FONT_VERDANA  = "$HOME/.local/share/fonts/Unknown\ Vendor/TrueType/Verdana"


  JABARI_ROBOTO_FAMILY   = "/home/daudi/Android/Sdk/platforms/android-29/data/fonts/"
  AKILI_ROBOTO_FAMILY   = "/usr/share/fonts/truetype/roboto/unhinted/RobotoTTF/"

  SYS_NAME = `uname -n`
  USE_FONT = ( SYS_NAME =~ /(jabari)|(akili)/ ?  "Roboto" : "Helvetica" )

  FONT_ROBOTO_FAMILY =  case  SYS_NAME
                        when /jabari/ then JABARI_ROBOTO_FAMILY
                        when /akili/  then AKILI_ROBOTO_FAMILY
                        else
                          nil
                        end


  ROBOTO_NORMAL   = "Roboto-Regular.ttf"
  ROBOTO_BOLD     = "Roboto-Bold.ttf"
  ROBOTO_BLACK    = "Roboto-Black.ttf"
  ROBOTO_ITALIC   = "Roboto-Italic.ttf"
  ROBOTO_LIGHT    = "Roboto-Light.ttf"
  ROBOTO_MEDIUM   = "Roboto-Medium.ttf"
  ROBOTO_LTITALIC = "Roboto-LightItalic.ttf"

  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
  #  CLASS-LEVEL actions & methods
  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
  def initialize( stroke = false)
    @pdf = Prawn::Document.new
    @done_heading = false
    @accum = []    # used to accumulate an entire array of conjugated tables
    
    if stroke 
      @pdf.stroke_axis
    end

    GenPdf.register_fonts( @pdf )
  end

  #  ------------------------------------------------------------
    #  register_fonts  -- register a new font family
    #  Roboto
  #  ------------------------------------------------------------
  def GenPdf.register_fonts( p )

    unless FONT_ROBOTO_FAMILY.nil?
      p.font_families.update(
        'Roboto' => {
          :normal   => FONT_ROBOTO_FAMILY+ROBOTO_NORMAL,
          :italic   => FONT_ROBOTO_FAMILY+ROBOTO_ITALIC,
          :bold     => FONT_ROBOTO_FAMILY+ROBOTO_BOLD,
          :black    => FONT_ROBOTO_FAMILY+ROBOTO_BLACK,
          :light    => FONT_ROBOTO_FAMILY+ROBOTO_LIGHT,
          :medium   => FONT_ROBOTO_FAMILY+ROBOTO_MEDIUM,
          :lt_italic   => FONT_ROBOTO_FAMILY+ROBOTO_LTITALIC
        }
      )
      p.fallback_fonts([USE_FONT])
    end

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
  #  turk_cap  -- special handling for capitalizing a turkish word
  #  returns
  #    new string with first letter capitalized
  #  -----------------------------------------------------------------
  def turk_cap( str )
    s = str.capitalize
    s[0] = case str[0]
           when /i/i  then  "İ"
           when /ı/i  then  "I"
           else
             str[0]
           end   # case
    return s          
  end

  #  -----------------------------------------------------------------
  #  heading -- renders the heading with verb and possible definition
  #  verb
  #  -----------------------------------------------------------------
  def heading( str )
    unless @done_heading
      @done_heading = true
      @pdf.bounding_box( 
          HEADING_POSITION, 
          height: HEADING_HEIGHT,
          width: HEADING_WIDTH
      ) do
        @pdf.font_size HEADING_FONT_SIZE 
        @pdf.pad( HEADING_PADDING ) {
          @pdf.text( turk_cap(str), style: :bold )
        }
        #  @pdf.transparent( 0.4 ) { @pdf.stroke_bounds }
      end  # bounding box block
    end   # unless
  end

  #  -----------------------------------------------------------------
  #  show_left_table  -- renders a left-hand table
  #  always moves down and starts at left
  #  
  #  -----------------------------------------------------------------
  def show_left_table(title, left_col, right_col)
    @pdf.font USE_FONT
    @pdf.move_down BOX_GAP_VERTICAL

    outer_top = @pdf.cursor

    @pdf.font USE_FONT
    @pdf.bounding_box(
      [0, outer_top],
      width: BOX_WIDTH,
      height: BOX_HEIGHT
    ) do
      @pdf.transparent( BOX_TRANSPARENCY ) { @pdf.stroke_bounds }
  
      @pdf.font_size BOX_TITLE_FONT_SIZE 
      @pdf.pad( BOX_TITLE_PADDING ) {
        @pdf.text( title, style: :italic , indent_paragraphs: BOX_TITLE_PADDING )
      }

      inner_top = @pdf.cursor  # remember inner columns top pt

        @pdf.font_size BOX_FONT_SIZE
      # left column
      @pdf.text_box( 
          left_col,
          at: [INNER_INDENT,inner_top], 
          width: INNER_WIDTH, 
          height: INNER_HEIGHT,
          overflow: :shrink_to_fit,
          min_font_size: BOX_MIN_FONT,
          style: :bold
      ) 

      # right column
      @pdf.text_box( 
          right_col,
          at: [INNER_INDENT+INNER_WIDTH,inner_top], 
          width: INNER_WIDTH, 
          height: INNER_HEIGHT,
          overflow: :shrink_to_fit,
          min_font_size: BOX_MIN_FONT,
          style: :bold
      )


    end  # table bounding box
    
    return outer_top   # remember top edge if paired tables
  end

  #  -----------------------------------------------------------------
  #  show_right_table  -- renders a right-hand table
  #  always moves bounding box to right, leaping over left table
  #  
  #  -----------------------------------------------------------------
  def show_right_table( top_edge, title, left_col, right_col )
    @pdf.font USE_FONT

    @pdf.bounding_box(
      [BOX_WIDTH + BOX_GAP_HORIZONTAL, top_edge ],
      width: BOX_WIDTH,
      height: BOX_HEIGHT
    ) do
      @pdf.transparent( BOX_TRANSPARENCY ) { @pdf.stroke_bounds }
      @pdf.font_size BOX_TITLE_FONT_SIZE 
      @pdf.pad( BOX_TITLE_PADDING ) {
        @pdf.text( title, style: :italic , indent_paragraphs: BOX_TITLE_PADDING )
      }

      inner_top = @pdf.cursor  # remember inner columns top pt

      # left column
      @pdf.font_size BOX_FONT_SIZE
      @pdf.text_box( 
          left_col,
          at: [INNER_INDENT,inner_top], 
          width: INNER_WIDTH, 
          height: INNER_HEIGHT,
          overflow: :shrink_to_fit,
          min_font_size: BOX_MIN_FONT,
          style: :bold
      )

      # right column
      @pdf.font_size BOX_FONT_SIZE
      @pdf.text_box( 
          right_col,
          at: [INNER_INDENT+INNER_WIDTH,inner_top], 
          width: INNER_WIDTH, 
          height: INNER_HEIGHT,
          overflow: :shrink_to_fit,
          min_font_size: BOX_MIN_FONT,
          style: :bold
      )


    end  # table bounding box
    
    return top_edge   # remember top edge if paired tables
   end

  #  -----------------------------------------------------------------
  #  render  -- renders the pdf, returning it
  #  -----------------------------------------------------------------
  def render
    @pdf.render
  end

  #  -----------------------------------------------------------------
  #  fileout  -- outputs the pdf file
  #  -----------------------------------------------------------------
  def fileout(verb)
    @pdf.render_file( verb.downcase + PDF_EXT )
  end
 
end  # class GenPdf

