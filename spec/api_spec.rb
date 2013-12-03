require 'spec_helper'
require './api'

require 'securerandom'

describe ECService::API do
  include Rack::Test::Methods

  def app
    ECService::API
  end

  describe "when GET /experiments" do
    it "must return all experiments" do
      get '/experiments'
      last_response.ok?.must_equal true
      JSON.parse(last_response.body).must_be_kind_of Array
    end
  end

  describe "when POST /experiments" do
    it  "must start an experiment" do
      new_exp = { name: "bob_#{SecureRandom.uuid}", props: { node1: 'n1' }.to_json, oedl: "defProperty('node1')\n" }
      post '/experiments', new_exp.to_json, "CONTENT_TYPE" => "application/json"
      last_response.status.must_equal 201
      created_exp = JSON.parse(last_response.body)
      created_exp['name'].must_match /bob_/
      JSON.parse(created_exp['props'])['node1'].must_match /n1/
      created_exp['oedl'].must_equal "defProperty('node1')\n"
    end

    it "must return error if no data posted" do
      post '/experiments'
      last_response.forbidden?.must_equal true
      JSON.parse(last_response.body)['error'].must_match /(name|props|oedl).*missing/
    end
  end

  describe "when GET /experiments/:name" do
    it "must get the information of an experiment" do
      skip
    end
  end

  describe "when POST /experiments/:name/stop" do
    it "must stop an experiment" do
      skip
    end
  end

  describe " when POST /experiments/:name/dump" do
    it "must dump the experiment database" do
      skip
    end
  end
end
