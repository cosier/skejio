require 'rails_helper'

RSpec.describe "twillio_tests/new", :type => :view do
  before(:each) do
    assign(:twillio_test, TwillioTest.new(
      :to_number => "MyString",
      :body => "MyText"
    ))
  end

  it "renders new twillio_test form" do
    render

    assert_select "form[action=?][method=?]", twillio_tests_path, "post" do

      assert_select "input#twillio_test_to_number[name=?]", "twillio_test[to_number]"

      assert_select "textarea#twillio_test_body[name=?]", "twillio_test[body]"
    end
  end
end
