require_dependency 'optimal_recipe_generator_from_usda_database/usda_food'
require_dependency 'optimal_recipe_generator_from_usda_database/ingredient'

class OptimalRecipeGeneratorFromUsdaDatabase
  include BenchmarkingHelpers

  def initialize(recipe_url, nutrient_profile_id, nutrient_names)
    @recipe_url = recipe_url
    @nutrient_profile_id = nutrient_profile_id
    @nutrient_names = nutrient_names
  end

  def generate
    measure('generate recipe') do
      profile(:generate_recipe) do
        generate_recipe(nutrient_profile, ingredients)
      end
    end
  end

  protected

  attr_reader :recipe_url, :nutrient_profile_id, :nutrient_names

  private

  def nutrient_profile
    diy_soylent_recipe.nutrient_profile
  end

  def diy_soylent_recipe
    DiySoylent::Recipe.fetch(recipe_url,
      nutrient_profile_id: nutrient_profile_id
    )
  end

  def ingredients
    usda_foods = measure('eager find usda foods') do
      eager_find_usda_foods
    end

    measure('build ingredients') do
      profile(:build_ingredients) do
        build_ingredients(usda_foods)
      end
    end
  end

  def eager_find_usda_foods
    usda_foods = find_usda_foods

    usda_foods_nutrients_by_nutrient_databank_number =
      find_usda_foods_nutrients(usda_foods).
      group_by { |food_nutrient| food_nutrient['nutrient_databank_number'] }

    usda_nutrients_by_nutrient_number =
      find_usda_nutrients(usda_foods_nutrients_by_nutrient_databank_number).
      index_by { |nutrient| nutrient['nutrient_number'] }

    usda_foods.each do |food|
      food_nutrients = usda_foods_nutrients_by_nutrient_databank_number[
        food['nutrient_databank_number']
      ]

      food_nutrients.each do |food_nutrient|
        food_nutrient['nutrient'] = usda_nutrients_by_nutrient_number[
          food_nutrient['nutrient_number']
        ]
      end

      food['foods_nutrients'] = food_nutrients
    end

    usda_foods
  end

  def find_usda_foods
    query = ::UsdaFood.selected.
      select(:nutrient_databank_number, :long_description)

    ActiveRecord::Base.connection.select_all(query.to_sql)
  end

  def find_usda_foods_nutrients(usda_foods)
    nutrient_databank_numbers = usda_foods.
      map { |food| food['nutrient_databank_number'] }.
      uniq

    query = UsdaNutrientDatabase::FoodsNutrient.
      select(:nutrient_databank_number, :nutrient_number, :nutrient_value).
      where(nutrient_databank_number: nutrient_databank_numbers)

    ActiveRecord::Base.connection.select_all(query.to_sql)
  end

  def find_usda_nutrients(usda_foods_nutrients_by_nutrient_databank_number)
    nutrient_numbers = usda_foods_nutrients_by_nutrient_databank_number.
      map { |_, food_nutrients|
        food_nutrients.map { |food_nutrient| food_nutrient['nutrient_number'] }
      }.
      flatten.
      uniq

    query = UsdaNutrientDatabase::Nutrient.
      select(:nutrient_number, :nutrient_description, :units).
      where(nutrient_number: nutrient_numbers)

    ActiveRecord::Base.connection.select_all(query.to_sql)
  end

  def build_ingredients(usda_foods)
    ingredients = []

    usda_foods.each do |food_row|
      usda_food = UsdaFood.from_row(food_row)
      ingredients << Ingredient.from_usda_food(usda_food)
    end

    ingredients
  end

  def generate_recipe(nutrient_profile, ingredients)
    OptimalRecipeGenerator.generate(
      nutrient_profile: nutrient_profile,
      ingredients: ingredients,
      nutrient_names: nutrient_names
    )
  end
end
