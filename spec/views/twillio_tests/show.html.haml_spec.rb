require 'rails_helper'

RSpec.describe "twillio_tests/show", :type => :view do
  before(:each) do
    @twillio_test = assign(:twillio_test, TwillioTest.create!(
      :to_number => "To Number",
      :body => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/To Number/)
    expect(rendered).to match(/MyText/)
  end
end
