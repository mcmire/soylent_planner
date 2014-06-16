class OptimalRecipeGenerator
  def self.limit; 2; end

  def self.call(options = {})
    new(options).call
  end

  attr_reader :nutrient_profile, :ingredients, :nutrients

  def initialize(nutrient_profile:, ingredients:)
    @nutrient_profile = build_nutrient_profile(nutrient_profile)
    @ingredients = build_ingredients(ingredients)
    @nutrients = build_nutrients(@nutrient_profile, @ingredients)
    @simplex_problem = build_simplex_problem
  end

  def call
    simplex_problem.debug!
    solution = simplex_problem.solve
    pp solution: solution
    Recipe.new(nutrient_profile, ingredients, solution)
  end

  private

  attr_reader :simplex_problem

  def build_simplex_problem
    Simplex.minimization_problem do |p|
      p.objective_coefficients = build_objective_coefficients

      build_constraints.each do |constraint|
        p.add_constraint(constraint)
      end
    end
  end

  def build_objective_coefficients
    ingredients.map do |ingredient|
      ingredient.normalized_cost.round(2).to_s.to_r
    end
  end

  def build_constraints
    rows = []

    nutrients[0...self.class.limit].each do |nutrient|
      coefficients = nutrient.ingredient_values
      min_value = nutrient.min_value.to_s.to_r
      max_value = nutrient.max_value.to_s.to_r

      rows << {
        coefficients: coefficients,
        operator: :>=,
        rhs_value: min_value
      }

      rows << {
        coefficients: coefficients,
        operator: :<=,
        rhs_value: max_value
      }

      puts "Total #{nutrient.name} must be between #{min_value} and #{max_value}"
    end

    rows
  end

  def build_nutrient_profile(nutrient_profile)
    NutrientProfile.new(nutrient_profile)
  end

  def build_ingredients(ingredients)
    ingredients[0...self.class.limit].map { |ingredient| Ingredient.new(ingredient) }
  end

  def build_nutrients(nutrient_profile, ingredients)
    NutrientCollection.modifiable_attribute_names[0...self.class.limit].map do |nutrient_name|
      ingredient_values = ingredients[0...self.class.limit].map do |ingredient|
        ingredient.normalized_value_for_nutrient(nutrient_name).round(2).to_s.to_r
      end

      Nutrient.new(
        name: nutrient_name,
        min_value: nutrient_profile.min_value_for_nutrient(nutrient_name),
        max_value: nutrient_profile.max_value_for_nutrient(nutrient_name),
        ingredient_values: ingredient_values
      )
    end
  end

  class NutrientProfile < SimpleDelegator
    def min_value_for_nutrient(nutrient_name)
      min_nutrient_collection.__send__(nutrient_name).to_f
    end

    def max_value_for_nutrient(nutrient_name)
      max_nutrient_collection.__send__(nutrient_name).to_f
    end
  end

  class Ingredient < SimpleDelegator
    def initialize(ingredient)
      super(ingredient)

      if serving_size.to_f == 0
        raise "Serving size for #{name} is 0?"
      end

      if cost.to_f == 0
        raise "Cost for #{name} is 0?"
      end
    end

    def value_for_nutrient(nutrient_name)
      (nutrient_collection.__send__(nutrient_name) || 0).to_f
    end

    def normalized_value_for_nutrient(nutrient_name)
      normalized_value = (value_for_nutrient(nutrient_name) / container_size).to_f
      puts "#{name} has #{value_for_nutrient(nutrient_name)} #{NutrientCollection.unit_for(nutrient_name)} of #{nutrient_name};\n  its container size is #{container_size} #{unit} which means the normalized value is #{normalized_value}"
      normalized_value
    end

    def normalized_cost
      normalized_cost = (cost / container_size).to_f
      puts "#{name} costs $#{cost};\n  its container size is #{container_size} #{unit} which means the normalized cost is $#{normalized_cost}"
      normalized_cost
    end
  end

  class Nutrient < SimpleDelegator
    attr_reader :name, :min_value, :max_value, :ingredient_values

    def initialize(name:, min_value:, max_value:, ingredient_values:)
      @name = name
      @min_value = min_value
      @max_value = max_value
      @ingredient_values = ingredient_values
    end
  end

  class Recipe
    attr_reader :nutrient_profile, :ingredients

    def initialize(nutrient_profile, ingredients, ingredient_amounts)
      @nutrient_profile = nutrient_profile
      pp ingredient_amounts: ingredient_amounts
      @ingredients = ingredients.zip(ingredient_amounts).map do |ingredient, ingredient_amount|
        RecipeIngredient.new(ingredient).tap do |recipe_ingredient|
          recipe_ingredient.daily_serving = ingredient_amount
          pp ingredient_name: recipe_ingredient.name,
             daily_serving: recipe_ingredient.daily_serving
        end
      end
    end

    def total_for_nutrient(nutrient_name)
      ingredients.sum do |ingredient|
        ingredient.multiplied_value_for_nutrient(nutrient_name)
      end
    end

    def percent_reached_for_nutrient(nutrient_name)
      total = total_for_nutrient(nutrient_name)
      max = nutrient_profile.max_value_for_nutrient(nutrient_name)
      total / max
    end
  end

  class RecipeIngredient < SimpleDelegator
    attr_accessor :daily_serving

    def multiplied_value_for_nutrient(nutrient_name)
      nutrient_value = normalized_value_for_nutrient(nutrient_name)

      if daily_serving && nutrient_value > 0
        (daily_serving * nutrient_value).round(2)
      else
        0
      end
    end
  end
end
