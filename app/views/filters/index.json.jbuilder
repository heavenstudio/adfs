json.array!(@filters) do |filter|
  json.extract! filter, :id, :name, :field_type, :filterable, :required
  json.url filter_url(filter, format: :json)
end
