class Ingredient < ActiveRecord::Base
  FORMS = %w(powder liquid paste pill)
  UNITS = %w(g ml portion pill)

  def self.forms; FORMS; end

  def self.units; UNITS; end

  def self.new_from_usda_food(usda_food)
    new do |ingredient|
      ingredient.name = usda_food.long_description

      nutrient_collection = ingredient.build_nutrient_collection
      usda_food.ingredient_attributes.each do |attribute_name, value|
        nutrient_collection.__send__("#{attribute_name}=", value)
      end
    end
  end

  validates :name, :form, :unit, :container_size, presence: true

  belongs_to :nutrient_collection, dependent: :destroy

  accepts_nested_attributes_for :nutrient_collection

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
end
