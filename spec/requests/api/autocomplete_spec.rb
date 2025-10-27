require 'rails_helper'

RSpec.describe "Api::Autocompletes", type: :request do
  describe "GET /doctors" do
    it "returns http success" do
      get "/api/autocomplete/doctors"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /specializations" do
    it "returns http success" do
      get "/api/autocomplete/specializations"
      expect(response).to have_http_status(:success)
    end
  end

end
