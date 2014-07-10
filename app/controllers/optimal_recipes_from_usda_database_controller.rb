class OptimalRecipesFromUsdaDatabaseController < ApplicationController
  include BenchmarkingHelpers

  def new
    @recipe_url = params.fetch(:recipe_url) do
      'http://diy.soylent.me/recipes/all-ingredients'
    end
    @nutrient_profile_id = params[:nutrient_profile_id]
  end

  def show
    @recipe_url = params[:recipe_url]
    @nutrient_profile_id = params[:nutrient_profile_id]
    @nutrient_names = ::NutrientCollection.modifiable_attribute_names

    if @recipe_url.present?
      diy_soylent_recipe = DiySoylent::Recipe.fetch(@recipe_url,
        nutrient_profile_id: @nutrient_profile_id
      )
      ingredients = fetch_ingredients
      @recipe = generate_recipe(diy_soylent_recipe.nutrient_profile, ingredients)
      render template: 'optimal_recipes/show'
    else
      flash[:danger] = "Missing recipe URL."
      redirect_to action: :new,
        recipe_url: @recipe_url,
        nutrient_profile_id: @nutrient_profile_id
    end
  end

  private

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

  def fetch_ingredients
    usda_foods = measure('fetch usda_foods') do
      eager_find_usda_foods
    end

    measure('fetch ingredients') do
      profile(:fetch_ingredients) do
        ingredients = []

        usda_foods.each do |food_row|
          usda_food = UsdaFood.from_row(food_row)
          ingredients << Ingredient.from_usda_food(usda_food)
        end

        ingredients
      end
    end
  end

  def generate_recipe(nutrient_profile, ingredients)
    measure('generate recipe') do
      profile(:generate_recipe) do
        OptimalRecipeGenerator.generate(
          nutrient_profile: nutrient_profile,
          ingredients: ingredients,
          nutrient_names: @nutrient_names
        )
      end
    end
  end

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

  class FoodsNutrient
    COLUMN_NAMES = %w(
      nutrient_databank_number
      nutrient_number
      nutrient_value
      nutrient
    )

    COLUMN_NAMES.each do |column_name|
      attr_accessor column_name
    end

    def self.from_row(row)
      new.tap do |foods_nutrient|
        COLUMN_NAMES.each do |column_name|
          foods_nutrient.__send__("#{column_name}=", row[column_name])
        end
      end
    end

    def nutrient=(nutrient)
      @nutrient = Nutrient.from_row(nutrient)
    end
  end

  class Nutrient
    COLUMN_NAMES = %w(nutrient_number nutrient_description units)

    COLUMN_NAMES.each do |column_name|
      attr_accessor column_name
    end

    def self.from_row(row)
      new.tap do |nutrient|
        COLUMN_NAMES.each do |column_name|
          nutrient.__send__("#{column_name}=", row[column_name])
        end
      end
    end
  end

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

  class NutrientCollection
    COLUMN_NAMES = ::NutrientCollection.column_names

    COLUMN_NAMES.each do |column_name|
      attr_accessor column_name
    end

    def self.from_row(row)
      new.tap do |nutrient_collection|
        COLUMN_NAMES.each do |column_name|
          nutrient_collection.__send__("#{column_name}=", row[column_name])
        end
      end
    end
  end
end
