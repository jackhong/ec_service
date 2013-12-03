require './model/experiment'

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
      end
      post do
        Experiment.create(name: params[:name])
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
