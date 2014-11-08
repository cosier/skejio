json.array!(@services) do |service|
  json.extract! service, :id, :business, :name, :description, :priority, :duration
  json.url service_url(service, format: :json)
end
