require 'redis'
require 'hiredis'

module ECService
  REDIS_NS = 'ec_s'

  module RedisHelper
    def redis
      @@redis ||= Redis.new(host: ENV['REDIS_HOST'], driver: :synchrony)
      #@@redis ||= Redis.new(host: ENV['REDIS_HOST'], driver: :hiredis)
    end

    # Faking redis for testing, need to require fakeredis gem
    def fake_redis!
      @@redis = Redis.new(host: ENV['REDIS_HOST'])
    end

    def ns(*keys)
      "#{REDIS_NS}:#{keys.join(':')}"
    end
  end
end
