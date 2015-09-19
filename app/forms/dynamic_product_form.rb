# This class works as a Product Proxy, but adding and validating dynamic fields
class DynamicProductForm
  include ActiveModel::Model
  extend ActiveModel::Naming

  # Attributes is the attributes list with default and dynamic attributes
  # Filters are the active filters (which define dynamic attributes)
  # Product is a reference to the product if it exists, or a new one
  def initialize(attributes: {}, filters: [], product: nil)
    @filters = filters
    @product = product || Product.new
    @attributes = cleanse_attributes(attributes)

    add_filter_accessors

    super(@attributes)
  end

  # Save the product to the database with its dynamic fields
  def save
    return false unless valid?
    @product.name = @attributes['name']
    set_dynamic_fields
    @product.save
  end

  def document
    @product
  end

  validate :field_validations
  validates :name, presence: true

  delegate :name, :name=, :persisted?, to: :@product

protected
  # Define dynamic getters and setters for dynamic fields for each filter
  def add_filter_accessors
    @filters.each do |filter|
      singleton_class.class_eval do
        define_method(filter.field_name) { @attributes[filter.field_name] }
        define_method("#{filter.field_name}=") { |value| @attributes[filter.field_name] = value }
      end
    end
  end

  def cleanse_attributes(attrs)
    return {} if attrs.blank?
    clean_attributes = {}
    attrs.stringify_keys!.each do |field, value|
      next if field.blank? || value.blank?
      next if ['_id', 'created_at', 'updated_at'].include?(field)
      if value.respond_to?(:select)
        clean_attributes[field] = value.select(&:present?)
      else
        clean_attributes[field] = value
      end
    end
    clean_attributes
  end

  # Validates presence of required fields
  def field_validations
    @filters.each do |filter|
      validate_field_presence(filter.field_name) if filter.required?
    end
  end

  def validate_field_presence(field_name)
    errors.add(field_name, I18n.t('errors.messages.blank')) if @attributes[field_name].blank?
  end

  def set_dynamic_fields
    dynamic_fields.each { |field| @product[field] = @attributes[field] }
  end

  def dynamic_fields
    @attributes.keys & @filters.map(&:field_name)
  end
end
