#!/usr/bin/env ruby
# Çekimi: Türkçe Fiil Çekimi
# Copyright (c) 2023 David S Anderson, All Rights Reserved
#
# cekimi_app.rb  -- starting point for sinatra web app
#

  require 'sinatra'
  require 'pp'   # pretty print
  require_relative 'view_helpers'
  require 'sinatra/form_helpers'

class CekimiApp < Sinatra::Application
  set :root, File.dirname(__FILE__)

  #  ------------------------------------------------------------
  #  prep_verb -- preprocessing for the verb & extensions
  #  returns processed verb
  #  ------------------------------------------------------------
  def prep_verb()
    verb = params[:v]
    query = request.env["rack.request.query_string"]

    unless query.empty?  # check for extensions
      verb << case query
        when /a/ then "#a"
        when /c/ then "#c"
        when /p/ then "#p"
        else
          ""
        end  # case
    end  # unless

    return verb
  end
   

  #  ------------------------------------------------------------
  #  ------------------------------------------------------------

  get '/' do
    haml :index
  end

  get '/list/:l' do
    @list = CEKIMI.do_list( ['list', params[:l] || "" ] ).split(/\n/)
    redirect '/'
  end

  get '/list' do
    @list = CEKIMI.do_list( ['list'] ).split(/\n/)
    haml :list
  end

  get '/about' do
    haml :about
  end

  get '/status' do
    @status = CEKIMI.do_status
    haml :status, :escape_html => false
  end

# http://localhost:3000/conj/+abc
  get '/flags/:f?' do
    @flags = CEKIMI.do_flags( ['flags', params[:f] || "" ] ).split /, /
    haml :flags
  end

  get '/help' do
    @help = CEKIMI.do_help
    haml :help
  end

  get '/version/?' do
    
    @version = CEKIMI.do_version
    haml :version
  end

# http://localhost:3000/conj/gitmek
  get '/conj/:v' do
    (@verb,  @definition, @tables) = CEKIMI.do_conjugate([ prep_verb ])

    @error = (
      @tables.nil? || @tables.empty?  ?  
      @verb + ": is an invalid entry! Türkçe bir fiil değildir." : 
      nil 
    )
    haml  :conjugate
  end   # outer do block

  get '/pdf/:v' do
    p = CEKIMI.do_conjugate([ prep_verb ], true)
    send_data( p.render, type: "application/pdf", disposition: "attachment" )
  end   # pdf

  post '/conj' do
    # pp request.env
    parms = params[:conj]
    # pp parms
    verb = parms[:verb] 
    verb = "silmek" if verb.empty?
    verb << case parms[:ext]
      when /yetenik/  then "?=a"
      when /nedensel/ then "?=c"
      when /pasif/    then "?=p"
      else
        ""
      end   # case

    if parms[:pdf].nil?
      redirect "/conj/#{verb}"
    else
      redirect "/pdf/#{verb}"
    end
  end
 
  #  ------------------------------------------------------------
  #  ------------------------------------------------------------
end  # CekimiApp 
