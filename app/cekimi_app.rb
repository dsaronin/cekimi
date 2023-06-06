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
    @greeting = "Merhaba, kolay gelsin. Buyurun istemde bir fiil girin." 
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
    tables = CEKIMI.do_conjugate([params[:v]])
    str = ""
    tables.each do |left,right|
      str << "#{left[0]}: #{left[1].gsub(/\n/,", ")} -- #{left[2].gsub(/\n/,", ")}" +
      "<br>#{right[0]}: #{right[1].gsub(/\n/,", ")} -- #{right[2].gsub(/\n/,", ")}\n" 
    end   # table output do block
    @verb = params[:v]
    @table_array = str.split(/\n/)
    haml  :conjugate
  end   # outer do block

 
  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
end  # CekimiApp 
