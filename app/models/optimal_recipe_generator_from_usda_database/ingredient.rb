require_dependency 'optimal_recipe_generator_from_usda_database/nutrient_collection'

class OptimalRecipeGeneratorFromUsdaDatabase
  class Ingredient
    COLUMN_NAMES = %w(
      name
      container_size
      cost
      serving_size
      nutrient_collection
      unit
    )

    COLUMN_NAMES.each do |column_name|
      attr_accessor column_name
    end

    def self.from_usda_food(usda_food)
      new.tap do |ingredient|
        ingredient.name = usda_food.long_description
        ingredient.container_size = 1000
        ingredient.cost = 100
        ingredient.serving_size = 100  # always
        ingredient.nutrient_collection =
          NutrientCollection.from_row(usda_food.ingredient_attributes)
        ingredient.unit = 'g'
      end
    end
  end
end
