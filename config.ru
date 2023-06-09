# config.ru

require 'sinatra'
require_relative './app/cekimi_work'
require_relative './app/cekimi_app'

configure do
  ENV['SINATRA_ENV'] ||= "development"
  ENV['RACK_ENV']    ||= "development"

  CEKIMI = CekimiWork.new 
  CEKIMI.setup_work()    # initialization of everything

  PUBLIC_DIR = File.join(File.dirname(__FILE__), 'public')
  set :public_folder, PUBLIC_DIR
  set :root, File.dirname(__FILE__)
  set :haml, { escape_html: false }

  Environ.log_info  "PUBLIC_DIR: #{PUBLIC_DIR}"
  Environ.log_info  ">>>> changing default flags: o, f"
  Environ.flags.parse_flags( [ '-o', '-f' ] )

end  # configure

run CekimiApp


# notes
# thin -R config.ru -a 127.0.0.1 -p 8080 start
#
# http://localhost:3000/
# curl http://localhost:4567/ -H "My-header: my data"

