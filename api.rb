require 'grape'
require 'base64'
require './worker'

module ECService
  NAMESPACE = 'ec_service'
  @@redis = Redis.new(host: 'localhost')

  def self.redis
    @@redis
  end

  def self.build_key(key)
    "#{NAMESPACE}:#{key.to_s}"
  end

  class API < Grape::API

    version 'v1', using: :header, vendor: 'omf'
    format :json

    rescue_from :all

    before do
      header['Access-Control-Allow-Origin'] = '*'
      header['Access-Control-Request-Method'] = '*'
    end

    resource :experiments do
      desc "Return all experiments"
      get do
        ECService.redis.smembers ECService.build_key(:experiments)
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

        ECService.redis.sadd ECService.build_key(:experiments), exp_name

        ECService.redis.set ECService.build_key(":oedl:#{exp_name}"), params[:oedl]
        ECService.redis.set ECService.build_key(":status:#{exp_name}"), :queued

        exp_props.each do |k, v|
          ECService.redis.hset ECService.build_key(":props:#{exp_name}"), k, v
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
          raise 'Experiment not found' unless  ECService.redis.sismember(ECService.build_key(:experiments), params[:name])
          exp_name = params[:name]
          {
            name: exp_name,
            status: ECService.redis.get(ECService.build_key(":status:#{exp_name}")),
            logs: ECService.redis.lrange(ECService.build_key(":logs:#{exp_name}"), 0, -1)
          }
        end
      end

      desc "Stop an experiment"
      desc "Dump the experiment database"
    end
  end
end
