require 'rails_helper'

RSpec.describe "twillio_tests/edit", :type => :view do
  before(:each) do
    @twillio_test = assign(:twillio_test, TwillioTest.create!(
      :to_number => "MyString",
      :body => "MyText"
    ))
  end

  it "renders the edit twillio_test form" do
    render

    assert_select "form[action=?][method=?]", twillio_test_path(@twillio_test), "post" do

      assert_select "input#twillio_test_to_number[name=?]", "twillio_test[to_number]"

      assert_select "textarea#twillio_test_body[name=?]", "twillio_test[body]"
    end
  end
end
