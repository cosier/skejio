json.array!(@businesses) do |manage_business|
  json.extract! manage_business, :id
  json.url manage_business_url(manage_business, format: :json)
end
