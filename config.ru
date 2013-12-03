require 'sidekiq'
require 'sidekiq/web'
require 'sinatra'
require 'sequel'
require 'grape'

Sequel.connect("postgres://localhost/ec_service_dev")
Sequel::Model.plugin :json_serializer
Sequel::Model.plugin :validation_helpers

require './worker'
require './app'
require './api'

run Rack::URLMap.new(
  '/monitor' => Sidekiq::Web,
  '/' => ECService::API
)
