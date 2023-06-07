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
    @greeting = "Merhaba, kolay gelsin."
    @hint = "Buyurun istemde bir fiil girin." 
    haml :index
  end

  get '/list/:l' do
    @list = CEKIMI.do_list( ['list'] ).split(/\n/)
    haml :list
  end

  get '/status' do
    @status = CEKIMI.do_status
    haml :status, :escape_html => false
  end

# http://localhost:3000/conj/+abc
  get '/flags/:f' do
    @flags = CEKIMI.do_flags( ['flags', params[:f]] ).split /, /
    haml :flags
  end

  get '/help' do
    @help = CEKIMI.do_help
    haml :help
  end

  get '/version' do
    @version = CEKIMI.do_version
    haml :version
  end

# http://localhost:3000/conj/gitmek
  get '/conj/:v' do
    @tables = CEKIMI.do_conjugate([params[:v]])
    @verb = params[:v]
    haml  :conjugate
  end   # outer do block

 
  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
end  # CekimiApp 
