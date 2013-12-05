require 'grape'
require 'sequel'
require 'base64'

Sequel.connect("postgres://localhost/ec_service_development")
Sequel::Model.plugin :json_serializer
Sequel::Model.plugin :validation_helpers

require './model/experiment'
require './worker'

module ECService
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
        Experiment.all
      end

      desc "Start an experiment"
      params do
        requires :name, type: String, desc: "Experiment name"
        requires :oedl, type: String, desc: "Experiment script (OEDL) body"
        optional :props, type: String, desc: "Properties provided to run experiment"
      end
      post do
        if (exp = Experiment.create(name: params[:name], oedl: params[:oedl], props: params[:props]))
          oedl_f = File.write("/tmp/#{exp.name}", Base64.decode64(exp.oedl))
          Worker.perform_async(exp.name, "/tmp/#{exp.name}", exp.props)
        end
        exp
      end

      desc "Get the information of an experiment"
      params do
        requires :name, type: String, desc: "Experiment name"
      end
      route_param :name do
        get do
          Experiment.where(name: params[:name])
        end
      end

      desc "Stop an experiment"
      desc "Dump the experiment database"
    end
  end
end
