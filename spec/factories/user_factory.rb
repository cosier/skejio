FactoryGirl.define do

  factory :user, class: 'User' do
    association :business

    first_name 'John'
    last_name 'Doe'

    # override this in your builder
    email "john.doe.#{Random.rand(9999)}@example.com"
    password '12345678'
    phone '+1 (555) 555-5555'
  end


end
