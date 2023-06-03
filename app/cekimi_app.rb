#!/usr/bin/env ruby
# Çekimi: Türkçe Fiil Çekimi
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#
# cekimi_app.rb  -- starting point for sinatra web app
#

  require 'sinatra'

class CekimiApp < Sinatra::Application
  set :root, File.dirname(__FILE__)
  #  ------------------------------------------------------------
  #  ------------------------------------------------------------

  get '/' do
    "Selam dünya! Çekimi: otomatik fiil çekimi yazılımı" 
  end
 
  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
end  # CekimiApp 