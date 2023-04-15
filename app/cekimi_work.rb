# Çekimi: Türkçe Fiil Çekimi
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#
# class CekimiWork -- main work module for doing everything
#

class CekimiWork
  require_relative 'environ'

  def initialize()
    @my_env = Environ.instance
  end

  def cekimi()
    setup_work()
    do_work()      # do the work of çekimi
    shutdown_work()

    return 1
  end

  def setup_work()
    Environ.log_info( "starting..." )
  end

  def do_work()
    Environ.put_prompt "\n\tçekimi: merhaba dunia!\n\n"
  end

  def shutdown_work()
    Environ.log_info( "...ending" )
  end

end
