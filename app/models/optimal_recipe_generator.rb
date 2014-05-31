class OptimalRecipeGenerator
  def self.call(options = {})
    new(options).call
  end

  def initialize(nutrient_profile:, ingredients:)
    @nutrient_profile = NutrientProfile.new(nutrient_profile)
    @ingredients = ingredients.to_a.map do |ingredient|
      Ingredient.new(ingredient)
    end
    @recipe = Recipe.new
  end

  def call
    [:calories, :carbohydrates, :protein, :total_fat].each do |nutrient_name|
      if ingredients.empty?
        break
      end

      nutrient_profile_nutrient = nutrient_profile.nutrients_by_name[nutrient_name]
      nutrient_total_value = recipe.nutrient_total_values_by_name[nutrient_name]
      effective_max_value = (
        nutrient_profile_nutrient.max_value -
        nutrient_total_value
      )
      candidate_ingredients = ingredients.
        select { |ingredient| ingredient.has_nutrient?(nutrient_name) }.
        map { |ingredient|
          ingredient_nutrient = ingredient.nutrients_by_name[nutrient_name]
          percentage_of_limit = ingredient_nutrient.normalized_value / effective_max_value
          [
            ingredient,
            ingredient_nutrient,
            percentage_of_limit
          ]
        }.
        select { |(_, ingredient_nutrient, _)|
          ingredient_nutrient &&
            ingredient_nutrient.value <= effective_max_value
        }.
        sort_by { |(_, _, percentage_of_limit)| percentage_of_limit }.
        reverse

      pp nutrient_name: nutrient_name,
         candidate_ingredients: candidate_ingredients.map { |a, b, c|
          [a.name, [b.name, b.value.to_f, b.unit], "#{(c.to_f * 100).round(2)}% of limit" ]
         }

      ingredient_closest_to_limit = candidate_ingredients[0]

      if ingredient_closest_to_limit
        found_ingredient = ingredient_closest_to_limit[0]
        calculated_daily_serving =
          found_ingredient.serving_size *
          (1 / ingredient_closest_to_limit[2])

        pp ingredient: ingredient_closest_to_limit[0].name,
           ingredient_normalized_serving_size: ingredient_closest_to_limit[0].normalized_serving_size,
           ingredient_nutrient_value: ingredient_closest_to_limit[1].value.to_f.round(2),
           ingredient_nutrient_normalized_value: ingredient_closest_to_limit[1].normalized_value.to_f.round(2),
           percentage: ingredient_closest_to_limit[2].to_f.round(2),
           calculated_daily_serving: calculated_daily_serving.to_f.round(2)

        recipe.add_ingredient(found_ingredient, calculated_daily_serving)
        ingredients.delete(found_ingredient)
      end
    end

    recipe
  end

  private

  attr_reader :nutrient_profile, :ingredients, :recipe

  class Recipe
    attr_reader :ingredients, :nutrient_total_values_by_name

    def initialize
      @ingredients = []
      @nutrient_total_values_by_name = Hash.new(0)
    end

    def add_ingredient(ingredient, serving_size)
      recipe_ingredient = RecipeIngredient.new(ingredient, serving_size)
      ingredients << recipe_ingredient
      increment_totals_for_nutrients_in(recipe_ingredient)
    end

    private

    def increment_totals_for_nutrients_in(ingredient)
      ingredient.nutrients.each do |nutrient|
        nutrient_total_values_by_name[nutrient.name] += (ingredient.factor * nutrient.value)
      end
    end
  end

  class RecipeIngredient < SimpleDelegator
    attr_reader :daily_serving

    def initialize(ingredient, daily_serving)
      super(ingredient)
      @daily_serving = daily_serving
    end

    def factor
      daily_serving / normalized_serving_size
    end
  end

  class Ingredient < SimpleDelegator
    attr_reader :nutrients_by_name, :nutrients, :normalized_serving_size

    def initialize(ingredient)
      super(ingredient)
      @normalized_serving_size = determine_normalized_serving_size
      @multiplier = determine_multiplier
      @nutrients_by_name, @nutrients = collect_nutrients_by_name

      if serving_size == 0
        raise "Serving size for #{name} is 0?"
      end
    end

    def has_nutrient?(nutrient_name)
      !!nutrients_by_name[nutrient_name]
    end

    private

    def collect_nutrients_by_name
      nutrients_by_name, nutrients = {}, []

      NutrientCollection.modifiable_attribute_names.inject({}) do |hash, nutrient_name|
        nutrient_value = nutrient_collection.__send__(nutrient_name)

        if nutrient_value
          normalized_nutrient_value = normalize(nutrient_value)
          #pp ingredient_name: name,
             #nutrient_name: nutrient_name,
             #nutrient_value: nutrient_value.to_f.round(2),
             #normalized_nutrient_value: normalized_nutrient_value.to_f.round(2),
             #serving_size: serving_size.to_f,
             #unit: unit
          nutrient_unit = NutrientCollection.unit_for(nutrient_name)
          ingredient_nutrient = IngredientNutrient.new(
            nutrient_name,
            nutrient_value,
            normalized_nutrient_value,
            nutrient_unit
          )
          nutrients << ingredient_nutrient
          nutrients_by_name[nutrient_name] = ingredient_nutrient
        end
      end

      [nutrients_by_name, nutrients]
    end

    def normalize(value)
      @multiplier * value
    end

    def determine_normalized_serving_size
      if unit == 'pill'
        1
      else
        100
      end
    end

    def determine_multiplier
      normalized_serving_size.to_f / serving_size
    end
  end

  class IngredientNutrient < Struct.new(:name, :value, :normalized_value, :unit); end

  class NutrientProfile < SimpleDelegator
    attr_reader :nutrients_by_name

    def initialize(nutrient_profile)
      super(nutrient_profile)
      @nutrients_by_name = collect_nutrients_by_name
    end

    private

    def collect_nutrients_by_name
      NutrientCollection.modifiable_attribute_names.inject({}) do |hash, name|
        min_value = min_nutrient_collection.__send__(name)
        max_value = max_nutrient_collection.__send__(name)

        if min_value && max_value
          hash[name] = NutrientProfileNutrient.new(min_value, max_value)
        end

        hash
      end
    end
  end

  class NutrientProfileNutrient < Struct.new(:min_value, :max_value); end
end
