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

  get '/list/:l' do
    CEKIMI.do_list( ['list'] )
  end

  get '/status' do
    CEKIMI.do_status
  end

# http://localhost:3000/conj/f=+abc
  get '/flags/:f' do
    "cekimi flags #{params[:f]}"
    CEKIMI.do_flags( ['flags', params[:f]] )
  end

  get '/help' do
    CEKIMI.do_help
  end

  get '/version' do
    CEKIMI.do_version
  end

# http://localhost:3000/conj/v=gitmek
  get '/conj/:v' do
    "conjugate #{params[:v]}"
  end

 
  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
end  # CekimiApp 
