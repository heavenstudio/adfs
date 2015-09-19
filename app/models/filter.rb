# pretty standard Mongoid model, nothing special here
class Filter
  include Mongoid::Document
  include Mongoid::Timestamps

  TYPES = %w(array text integer boolean)

  default_scope -> { order_by(:created_at.asc) }

  field :name, type: String
  field :field_name, type: String
  field :field_type, type: String
  field :filterable, type: Mongoid::Boolean, default: false
  field :required, type: Mongoid::Boolean, default: false
  field :options, type: Array, default: []

  validates :name, presence: true
  validates :field_type, presence: true
  validates :field_name,
    presence: true,
    format: { with: /\A[a-z_]+\z/, message: 'só pode conter letras de "a" à "z" e "_"' },
    uniqueness: true

  scope :filterable, -> { where(filterable: true) }
end
