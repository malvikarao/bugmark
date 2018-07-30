require 'rails_helper'

include AuthRequestHelper

describe "API" do
  context 'GET /events' do

    it 'fails w/o valid login' do
      get "/api/v1/events"
      expect(response.status).to eq(401)
    end

    it 'works with valid login' do
      create_user
      get "/api/v1/events.json", env: basic_creds
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end
end
