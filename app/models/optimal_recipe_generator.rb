# TODO: Change this to maximize the total average percentage reached instead of
# minimizing cost
#
# Can you also try an alternate approach, where you start with the ingredient
# that has the most of the first nutrient, add as much as we can for each
# nutrient, move to the next ingredient, add as much as we can for all
# nutrients, etc.? This is a greedy approach...

class OptimalRecipeGenerator
  PRECISION = 2
  #PRECISION = nil

  def self.round(number)
    if PRECISION
      number.round(PRECISION)
    else
      number
    end
  end

  def self.rationalize(number)
    round(number).to_s.to_r
  end

  def self.generate(options = {})
    generator = new(options)

    #until recipe = generator.generate
      #generator.lower_constraints!
    #end

    #recipe

    generator.generate
  end

  attr_reader :nutrient_profile, :ingredients, :nutrients, :recipe

  def initialize(nutrient_profile:, ingredients:, nutrient_names:)
    @nutrient_profile = build_nutrient_profile(nutrient_profile)
    @ingredients = build_ingredients(@nutrient_profile, ingredients)
    @nutrient_names = nutrient_names
    @nutrients = build_nutrients(@nutrient_profile, @ingredients)
    @objective_coefficients = build_objective_coefficients
    @constraints = build_constraints

    pp objective_coefficients: objective_coefficients,
       constraints: constraints
  end

  def generate
    simplex_problem = build_simplex_problem
    solution = simplex_problem.solve
    Recipe.new(nutrient_profile, ingredients, solution)
  rescue Simplex::UnboundedProblem
    nil
  end

  def lower_constraints!
    constraints.each do |constraint|
      start_value = constraint[:range].first

      if start_value
        start_value -= 10

        if start_value < 0
          start_value = nil
        end
      end

      end_value = constraint[:range].last

      constraint[:range] = [start_value, end_value]
    end
  end

  private

  attr_reader :nutrient_names, :objective_coefficients, :constraints,
    :simplex_problem

  def build_simplex_problem
    #problem = Simplex.minimization_problem do |p|
    problem = Simplex.maximization_problem do |p|
      p.objective_coefficients = objective_coefficients

      constraints.each do |constraint|
        a_coefficient_is_more_than_zero =
          constraint[:coefficients].any? { |value| value > 0 }

        if constraint[:range].first && a_coefficient_is_more_than_zero
          p.add_constraint(
            coefficients: constraint[:coefficients],
            operator: :>=,
            rhs_value: constraint[:range].first
          )
        end

        if constraint[:range].last && a_coefficient_is_more_than_zero
          p.add_constraint(
            coefficients: constraint[:coefficients],
            operator: :<=,
            rhs_value: constraint[:range].last
          )
        end
      end
    end

    problem.debug!

    problem
  end

  def build_objective_coefficients
    normalized_nutrient_value_totals_by_name.map do |nutrient_name, total|
      max_value = nutrient_profile.max_value_for_nutrient(nutrient_name)

      if !max_value || max_value == 0
        0
      else
        total.to_f / max_value.to_f
      end
    end
  end

  def build_constraints
    nutrients.each_with_index.inject([]) do |constraints, (nutrient, index)|
      coefficients = nutrient.ingredient_values
      min_value = nutrient.min_value.to_s.to_r
      max_value = nutrient.max_value.to_s.to_r

      #if index == 0
        #constraints << {
          #coefficients: [1] + Array.new(coefficients.size-1, 0),
          #range: [nil, 100]
        #}
      #end

      if min_value.to_f > 0 && max_value.to_f > 0
        constraints << {
          coefficients: coefficients,
          range: [min_value, max_value]
        }
      elsif max_value.to_f < 0
        raise "#{nutrient.name}'s max_value is 0 or undefined"
      end

      constraints
    end
  end

  def normalized_nutrient_value_totals_by_name
    totals_by_nutrient_name = Hash.new(0)

    ingredients.each do |ingredient|
      nutrients.each_with_index do |nutrient, index|
        totals_by_nutrient_name[nutrient.name] +=
          ingredient.normalized_value_for_nutrient(nutrient.name)
      end
    end

    pp totals_by_nutrient_name: totals_by_nutrient_name

    totals_by_nutrient_name
  end

  def build_nutrient_profile(nutrient_profile)
    NutrientProfile.new(nutrient_profile)
  end

  def build_ingredients(nutrient_profile, ingredients)
    ingredients.
      map { |ingredient| Ingredient.new(nutrient_profile, ingredient) }.
      reject { |ingredient| ingredient.serving_size.to_i == 0 }
  end

  def build_nutrients(nutrient_profile, ingredients)
    nutrient_names.map do |nutrient_name|
      ingredient_values = ingredients.map do |ingredient|
        OptimalRecipeGenerator.rationalize(
          ingredient.normalized_value_for_nutrient(nutrient_name)
        )
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
      min_nutrient_collection.__send__(nutrient_name)
    end

    def max_value_for_nutrient(nutrient_name)
      max_nutrient_collection.__send__(nutrient_name)
    end
  end

  class Ingredient < SimpleDelegator
    def initialize(nutrient_profile, ingredient)
      @nutrient_profile = nutrient_profile

      super(ingredient)

      if cost.to_f == 0
        raise "Cost for #{name} is 0?"
      end

      if serving_size.to_f == 0
        warn "Serving size for #{name} is 0, ignoring"
      end
    end

    def value_for_nutrient(nutrient_name)
      (nutrient_collection.__send__(nutrient_name) || 0).to_f
    end

    def normalized_value_for_nutrient(nutrient_name)
      normalized_value = (value_for_nutrient(nutrient_name) / container_size).to_f
      #puts "#{name} has #{value_for_nutrient(nutrient_name)} #{NutrientCollection.unit_for(nutrient_name)} of #{nutrient_name};\n  its container size is #{container_size} #{unit} which means the normalized value is #{normalized_value}"
      normalized_value
    end

    def normalized_cost
      normalized_cost = (cost / container_size).to_f
      #puts "#{name} costs $#{cost};\n  its container size is #{container_size} #{unit} which means the normalized cost is $#{normalized_cost}"
      normalized_cost
    end

    def value_to_max_ratio_for_nutrient(nutrient_name)
      value = value_for_nutrient(nutrient_name)
      max_value = nutrient_profile.max_value_for_nutrient(nutrient_name)

      if value.to_i == 0 || max_value.to_i == 0
        0
      else
        value / max_value
      end
    end

    private

    attr_reader :nutrient_profile
  end

  class Nutrient < SimpleDelegator
    attr_reader :name, :min_value, :max_value, :ingredient_values

    def initialize(
      name:,
      min_value:,
      max_value:,
      ingredient_values:
    )
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
      #pp ingredient_amounts: ingredient_amounts
      @ingredients = ingredients.zip(ingredient_amounts).map do |ingredient, ingredient_amount|
        RecipeIngredient.new(ingredient).tap do |recipe_ingredient|
          recipe_ingredient.daily_serving = ingredient_amount
          #pp ingredient_name: recipe_ingredient.name,
             #daily_serving: recipe_ingredient.daily_serving
        end
      end
    end

    def total_cost
      ingredients.sum(&:cost)
    end

    def total_for_nutrient(nutrient_name)
      ingredients.sum do |ingredient|
        ingredient.multiplied_value_for_nutrient(nutrient_name)
      end
    end

    def percent_reached_for_nutrient(nutrient_name)
      total = total_for_nutrient(nutrient_name)
      max = nutrient_profile.max_value_for_nutrient(nutrient_name)

      if max
        if max == 0
          0
        else
          total / max
        end
      end
    end

    def total_multiplied_cost
      ingredients.sum(&:multiplied_cost)
    end
  end

  class RecipeIngredient < SimpleDelegator
    attr_accessor :daily_serving

    def multiplied_value_for_nutrient(nutrient_name)
      nutrient_value = normalized_value_for_nutrient(nutrient_name)

      if daily_serving && nutrient_value > 0
        OptimalRecipeGenerator.round(daily_serving * nutrient_value)
      else
        0
      end
    end

    def multiplied_cost
      if daily_serving
        OptimalRecipeGenerator.round(daily_serving * normalized_cost)
      else
        0
      end
    end
  end
end
