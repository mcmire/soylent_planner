require_dependency 'optimal_recipe_generator_from_usda_database/foods_nutrient'

class OptimalRecipeGeneratorFromUsdaDatabase
  class UsdaFood
    COLUMN_NAMES = %w(
      nutrient_databank_number
      long_description
      foods_nutrients
    )

    COLUMN_NAMES.each do |column_name|
      attr_accessor column_name
    end

    def self.from_row(row)
      new.tap do |food|
        COLUMN_NAMES.each do |column_name|
          food.__send__("#{column_name}=", row[column_name])
        end
      end
    end

    def ingredient_attributes
      ingredient_attribute_builder.call
    end

    def foods_nutrients=(foods_nutrients)
      @foods_nutrients = foods_nutrients.map do |foods_nutrient|
        FoodsNutrient.from_row(foods_nutrient)
      end
    end

    private

    def ingredient_attribute_builder
      @_ingredient_attribute_builder ||=
        ::UsdaFood::IngredientAttributeBuilder.new(self)
    end
  end
end
