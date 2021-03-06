class UsdaFood::IngredientAttributeBuilder::AttributeValueProducer
  attr_reader :attribute_name

  def initialize(attribute_builder, attribute_name, nutrient_numbers)
    @attribute_builder = attribute_builder
    @attribute_name = attribute_name
    @nutrient_numbers = Array(nutrient_numbers).map(&:to_i)
  end

  def call
    nutrient_values.sum
  end

  private

  attr_reader :attribute_builder, :nutrient_numbers

  delegate :foods_nutrients_by_nutrient_number, to: :attribute_builder

  def copyable_nutrient_numbers
    nutrient_numbers & foods_nutrients_by_nutrient_number.keys
  end

  def foods_nutrients
    copyable_nutrient_numbers.map do |nutrient_number|
      foods_nutrients_by_nutrient_number[nutrient_number]
    end
  end

  def nutrient_values
    foods_nutrients.map do |foods_nutrient|
      begin
        from_unit = foods_nutrient.nutrient.units
        to_unit = NutrientCollection.unit_for(attribute_name)
        unit_converter.convert(foods_nutrient.nutrient_value,
          from_unit: from_unit,
          to_unit: to_unit
        )
      rescue ArgumentError
        raise ArgumentError, "Don't know how to convert #{attribute_name} from #{from_unit} to #{to_unit}"
      end
    end
  end

  def unit_converter
    @_unit_converter ||= UnitConverter.new
  end
end
