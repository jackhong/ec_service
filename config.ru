require './api'

use Rack::Stream

map '/' do
  run ECService::API
end

map'/monitor' do
  run Sidekiq::Web
end

map '/test' do
  run Rack::File.new("./test.html")
end
