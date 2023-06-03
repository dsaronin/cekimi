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

  get '/list' do
    "cekimi list"
  end

  get '/status' do
    "cekimi status"
  end

# http://localhost:3000/conj/f=+abc
  get '/flags/:f' do
    "cekimi flags #{params[:f]}"
  end

  get '/help' do
    "cekimi help"
    CEKIMI.do_help
  end

  get '/version' do
    "cekimi version"
  end

# http://localhost:3000/conj/v=gitmek
  get '/conj/:v' do
    "conjugate #{params[:v]}"
  end

 
  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
end  # CekimiApp 
