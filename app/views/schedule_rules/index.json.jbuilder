json.array!(@schedule_rules) do |schedule_rule|
  json.extract! schedule_rule, :id, :service_provider_id, :business_id
  json.url schedule_rule_url(schedule_rule, format: :json)
end
