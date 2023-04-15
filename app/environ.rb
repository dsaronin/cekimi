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

  @@logger = Logger.new(STDERR)


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

  
end  # Class Environ
