namespace :migration do
  task copy_usda_foods_to_ingredients: :environment do
    foods = UsdaNutrientDatabase::Food.limit(1).map do |food|
      {
        food: food.long_description,
        food_group: food.food_group.description,
        nutrients: food.foods_nutrients.map { |food_nutrient|
          {
            value: food_nutrient.nutrient_value,
            description: food_nutrient.nutrient.nutrient_description,
            units: food_nutrient.nutrient.units
          }
        },
        weights: food.weights.map { |weight|
          {
            amount: weight.amount,
            description: weight.measurement_description
          }
        }
      }
    end

    # ...
  end
end
