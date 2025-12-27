require 'rails_helper'

RSpec.describe "Reviews", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/reviews/show"
      expect(response).to have_http_status(:success)
    end
  end

end
