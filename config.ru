# config.ru

require 'sinatra'
require_relative './app/cekimi_work'
require_relative './app/cekimi_app'

configure do
  CEKIMI = CekimiWork.new 
  CEKIMI.setup_work()    # initialization of everything
end  # configure

run CekimiApp


# notes
# thin -R config.ru -a 127.0.0.1 -p 8080 start
#
# http://localhost:4567/
# curl http://localhost:4567/ -H "My-header: my data"

