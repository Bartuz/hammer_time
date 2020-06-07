require "sinatra"
require "sinatra/base"
require "sinatra/reloader"

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/health' do
    'Breathing'
  end
end
