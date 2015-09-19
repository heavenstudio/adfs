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

  # we define search fields here
  searchable do
    text :name

    # for each dynamic filter we declare its corresponding database value
    # you may also want / need to store references to other objects instead of the
    # actual object value / String in more complex scenarios
    dynamic_string :filters, multiple: true do
      Filter.filterable.inject({}) do |hash, filter|
        field = filter.field_name
        hash[field.to_sym] = self[field] if respond_to?(field)
        hash
      end
    end
  end
end
