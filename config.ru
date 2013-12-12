require 'grape'
require 'base64'
require 'redis'
require 'hiredis'

require './worker'
require './api'

require 'sidekiq/web'
run Rack::URLMap.new('/' => ECService::API, '/monitor' => Sidekiq::Web)
