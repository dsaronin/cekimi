#!/usr/bin/env ruby


  require_relative 'ansicolor'
  include AnsiColor

  require 'logger'
  @logger = Logger.new(STDERR)

  def main()
    put_prompt "\n\tçekimi: merhaba dunia!\n\n"

    @logger.debug wrapYellow "debug test message"
    @logger.info wrapCyan "info test message"
    @logger.warn wrapGreen "warn test message"
    @logger.error wrapRed "error test message"

    setup_work()
    work()      # do the work of çekimi
    shutdown_work()

    return 1
  end

  def setup_work()
  end

  def work()
  end

  def shutdown_work()
  end

  exit main()



