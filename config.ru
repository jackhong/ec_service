require './worker'
require './api'

require 'sidekiq/web'

run Rack::URLMap.new('/' => ECService::API, '/monitor' => Sidekiq::Web)
