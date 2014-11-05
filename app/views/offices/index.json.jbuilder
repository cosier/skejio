json.array!(@offices) do |business_office|
  json.extract! business_office, :id, :business_id, :name, :location
  json.url business_office_url(business_office, format: :json)
end
