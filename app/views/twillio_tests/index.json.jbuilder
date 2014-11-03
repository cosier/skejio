json.array!(@twillio_tests) do |twillio_test|
  json.extract! twillio_test, :id, :to_number, :body
  json.url twillio_test_url(twillio_test, format: :json)
end
