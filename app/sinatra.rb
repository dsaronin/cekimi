#!/usr/bin/env ruby
# Çekimi: Türkçe Fiil Çekimi
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#
# sinatra.rb  -- starting point for sinatra web app
#

  require_relative 'cekimi_work'

  cw = CekimiWork.new
  cw.setup_work()    # initialization of everything


  #  ------------------------------------------------------------
  #  ------------------------------------------------------------

  get '/' do
    "Selam dünya! Çekimi: otomatik fiil çekimi yazılımı" 
  end
 
  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
 
