# Çekimi: Türkçe Fiil Çekimi
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#
# class Environ -- sets up & control environment for application
# SINGLETON: invoke as Environ.instance
#
#
#----------------------------------------------------------
# requirements
#----------------------------------------------------------
  require 'logger'
  require_relative 'ansicolor'
  require 'singleton'
#----------------------------------------------------------

class Environ
  include Singleton
  
# constants ... #TODO replace with config file?
  APP_NAME = "Çekimi"
  APP_NAME_HEAD = APP_NAME + ": "
  CEKIMI_VERSION = "0.01"
  CEKIMI_HELP = "list (l), status (s), options (o), help (h), quit (q), exit (x)"

# initialize the class-level instance variables
  @cekimi_version = CEKIMI_VERSION
  @app_name = APP_NAME 
  @app_name_head = APP_NAME_HEAD 
  @cekimi_help = CEKIMI_HELP 


  class << self   
        # mixin AnsiColor Module to provide prettier ansi output
        # makes all methods in AnsiColor become Environ class methods
    include AnsiColor
        # makes the following class-level instance variables w/ accessors
    attr_accessor :cekimi_version, :app_name, :app_name_head, :cekimi_help
  end
  
  @@logger = Logger.new(STDERR)


  # log_debug -- wraps a logger message in AnsiColor & Cekimi name
  def Environ.log_debug( msg )
    @@logger.debug wrapYellow app_name_head + msg
  end

  # log_info -- wraps a logger message in AnsiColor & Cekimi name
  def Environ.log_info( msg )
    @@logger.info wrapCyan app_name_head + msg
  end

  # log_warn -- wraps a logger message in AnsiColor & Cekimi name
  def Environ.log_warn( msg )
    @@logger.warn wrapGreen app_name_head + msg
  end

  # log_error -- wraps a logger message in AnsiColor & Cekimi name
  def Environ.log_error( msg )
    @@logger.error wrapRed APP_NAME_HEAD + msg
  end

  # log_fatal -- wraps a logger message in AnsiColor & Cekimi name
  def Environ.log_fatal( msg )
    @@logger.fatal wrapRedBold app_name_head + msg
  end

  
  # get_input_list  -- returns an array of input line arguments
  # arg:  exit_cmd -- a command used if EOF is encountered; to force exit
  # input line will be stripped of lead/trailing whitespace
  # will then be split into elements using whitespace as delimiter
  # resultant non-nil (but possibly empty) list is returned
  def Environ.get_input_list( exit_cmd = "q" )
    # check for EOF nil and replace with exit_cmd if was EOF
    return  (gets || exit_cmd ).strip.split
  end

  def Environ.put_and_log_error( str )
    self.put_error( str )
    self.log_error( str )
  end


  
end  # Class Environ
