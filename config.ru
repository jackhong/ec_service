require 'sidekiq/web'
require './worker'
require './app'

run Rack::URLMap.new('/' => Sinatra::Application, '/sidekiq' => Sidekiq::Web)


