require "rails_helper"

RSpec.describe TwillioTestsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/twillio_tests").to route_to("twillio_tests#index")
    end

    it "routes to #new" do
      expect(:get => "/twillio_tests/new").to route_to("twillio_tests#new")
    end

    it "routes to #show" do
      expect(:get => "/twillio_tests/1").to route_to("twillio_tests#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/twillio_tests/1/edit").to route_to("twillio_tests#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/twillio_tests").to route_to("twillio_tests#create")
    end

    it "routes to #update" do
      expect(:put => "/twillio_tests/1").to route_to("twillio_tests#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/twillio_tests/1").to route_to("twillio_tests#destroy", :id => "1")
    end

  end
end
