require 'grape'
require 'base64'
require 'rack/stream'
require 'sidekiq/web'

require './helper/redis'
require './worker'

module ECService
  class API < Grape::API
    version 'v1', using: :header, vendor: 'omf'
    format :json

    rescue_from :all

    helpers do
      include Rack::Stream::DSL
      include ECService::RedisHelper
    end

    before do
      header['Access-Control-Allow-Origin'] = '*'
      header['Access-Control-Request-Method'] = '*'
    end

    resource :experiments do
      desc "Return all experiments"
      get do
        exps = redis.smembers ns(:experiments)
      end

      desc "Start an experiment"
      params do
        requires :name, type: String, desc: "Experiment name"
        requires :oedl, type: String, desc: "Experiment script (OEDL) body"
        optional :props, type: Hash, desc: "Properties provided to run experiment"
      end
      post do
        exp_name = params[:name]
        exp_props = params[:props] || []

        redis.sadd ns(:experiments), exp_name

        redis.set ns(:oedl, exp_name), params[:oedl]
        redis.set ns(:status, exp_name), :queued

        exp_props.each do |k, v|
          redis.hset ns(:props, exp_name), k, v
        end

        oedl_f = File.write("/tmp/#{exp_name}", Base64.decode64(params[:oedl]))
        Worker.perform_async(exp_name, "/tmp/#{exp_name}", exp_props)

        { name: exp_name }
      end

      desc "Get the information of an experiment"
      params do
        requires :name, type: String, desc: "Experiment name"
      end
      route_param :name do
        get do
          raise 'Experiment not found' unless redis.sismember(ns(:experiments), params[:name])
          exp_name = params[:name]
          {
            name: exp_name,
            status: redis.get(ns(:status, exp_name)),
            logs: redis.lrange(ns(:logs, exp_name), 0, -1)
          }
        end
      end

      desc "Stop an experiment"
      desc "Dump the experiment database"

      desc "Monitor the log output of an experiment"
      params do
        requires :name, type: String, desc: "Experiment name"
      end
      route_param :name do
        get :log_events do
          exp_name = params[:name]

          after_open do
            redis_pubsub.subscribe(ns(:log_events, exp_name)) do |on|
              on.message do |channel, msg|
                chunk msg
              end
            end
          end
          redis.lrange(ns(:logs, exp_name), 0, -1)
        end
      end

    end
  end
end
