class Ingredient < ActiveRecord::Base
  FORMS = %w(powder liquid paste pill)
  UNITS = %w(g ml portion pill)
  ATTRIBUTES_TO_EXCLUDE_FROM_DIGEST = [
    'id',
    'nutrient_collection_id',
    'created_at',
    'updated_at',
    'digest',
    'daily_serving'
  ]

  def self.forms; FORMS; end

  def self.units; UNITS; end

  def self.from_usda_food(usda_food)
    new do |ingredient|
      ingredient.from_usda_food = true
      ingredient.name = usda_food.long_description
      ingredient.container_size = 1000
      ingredient.cost = 100
      ingredient.serving_size = 100  # always
      ingredient.build_nutrient_collection(usda_food.ingredient_attributes)
    end
  end

  def self.duplicates
    by_calculated_digest.
      select { |digest, ingredients| ingredients.size > 1 }.
      flat_map { |digest, ingredients| ingredients[1..-1] }
  end

  def self.by_calculated_digest
    all.group_by(&:calculated_digest)
  end

  validates :name, :form, :unit, :container_size, presence: true

  belongs_to :nutrient_collection, dependent: :destroy

  before_save :write_digest

  accepts_nested_attributes_for :nutrient_collection

  attr_accessor :from_usda_food

  def form=(form)
    unless FORMS.include?(form)
      raise ArgumentError, "Invalid form '#{form}'. Valid forms are: #{FORMS}"
    end

    super
  end

  def unit=(unit)
    unless UNITS.include?(unit)
      raise ArgumentError, "Invalid unit '#{unit}'. Valid units are: #{UNITS}"
    end

    super
  end

  def formatted_unit_for(attribute_name)
    NutrientCollection.unit_for(attribute_name) + ' per serving'
  end

  def calculated_digest
    Digest::MD5.hexdigest(
      json_encoded_attributes +
      nutrient_collection.calculated_digest
    )
  end

  private

  def write_digest
    self.digest = calculated_digest
  end

  def json_encoded_attributes
    attributes = self.attributes.except(*ATTRIBUTES_TO_EXCLUDE_FROM_DIGEST)

    if attributes['link']
      attributes.delete('cost')
    end

    attributes = attributes.to_a.sort { |a, b| a[0] <=> b[0] }

    JSON.generate(attributes)
  end
end
