require 'rails_helper'

RSpec.describe "twillio_tests/index", :type => :view do
  before(:each) do
    assign(:twillio_tests, [
      TwillioTest.create!(
        :to_number => "To Number",
        :body => "MyText"
      ),
      TwillioTest.create!(
        :to_number => "To Number",
        :body => "MyText"
      )
    ])
  end

  it "renders a list of twillio_tests" do
    render
    assert_select "tr>td", :text => "To Number".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
