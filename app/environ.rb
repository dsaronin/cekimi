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

# mixin AnsiColor Module to provide prettier ansi output
# makes all methods in AnsiColor become Environ class methods
  class << self   
    include AnsiColor
  end
  
# constants ... #TODO replace with config file?
  APP_NAME = "Çekimi"
  APP_NAME_HEAD = APP_NAME + ": "
  CEKIMI_VERSION = "0.01"
  CEKIMI_HELP = "list (l), status (s), options (o), help (h), quit (q), exit (x)"

  @@logger = Logger.new(STDERR)

  def Environ.get_version   
    return CEKIMI_VERSION  
  end

  def Environ.get_help_str   
    return CEKIMI_HELP  
  end


  # log_debug -- wraps a logger message in AnsiColor & Cekimi name
  def Environ.log_debug( msg )
    @@logger.debug wrapYellow APP_NAME_HEAD + msg
  end

  # log_info -- wraps a logger message in AnsiColor & Cekimi name
  def Environ.log_info( msg )
    @@logger.info wrapCyan APP_NAME_HEAD + msg
  end

  # log_warn -- wraps a logger message in AnsiColor & Cekimi name
  def Environ.log_warn( msg )
    @@logger.warn wrapGreen APP_NAME_HEAD + msg
  end

  # log_error -- wraps a logger message in AnsiColor & Cekimi name
  def Environ.log_error( msg )
    @@logger.error wrapRed APP_NAME_HEAD + msg
  end

  # log_fatal -- wraps a logger message in AnsiColor & Cekimi name
  def Environ.log_fatal( msg )
    @@logger.fatal wrapRedBold APP_NAME_HEAD + msg
  end

  # get_prompt: returns the app name as the prompt string
  def Environ.get_prompt  
    return APP_NAME
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


  
end  # Class Environ
