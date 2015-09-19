class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  # This allows us to add and update model attributes dynamically
  # We can add non defined attributes using [] notation
  # e.g.: product[:new_field] = 'some value'
  include Mongoid::Attributes::Dynamic

  # This adds the sunspot adapter for this model, making it easy to index fields
  include Sunspot::Mongoid2

  field :name, type: String

  # fetchs only attributes defined dynamically
  def dynamic_fields
    attributes.keys - fields.keys
  end

  searchable do
    text :name

    dynamic_string :filters, multiple: true do
      Filter.filterable.inject({}) do |hash, filter|
        field = filter.field_name
        hash[field.to_sym] = self[field] if respond_to?(field)
        hash
      end
    end
  end
end
