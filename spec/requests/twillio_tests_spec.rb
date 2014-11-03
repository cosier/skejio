require 'rails_helper'

RSpec.describe "TwillioTests", :type => :request do
  describe "GET /twillio_tests" do
    it "works! (now write some real specs)" do
      get twillio_tests_path
      expect(response).to have_http_status(200)
    end
  end
end
