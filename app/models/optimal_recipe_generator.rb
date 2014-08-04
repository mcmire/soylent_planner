# TODO: Can you also try an alternate approach, where you start with the
# ingredient that has the most of the first nutrient, add as much as we can for
# each nutrient, move to the next ingredient, add as much as we can for all
# nutrients, etc.? This is a greedy approach...

class OptimalRecipeGenerator
  Error = Class.new(StandardError)

  class << self
    attr_accessor :profile, :debug
  end

  self.profile = ENV['PROFILE_OPTIMAL_RECIPE_GENERATOR']
  self.debug = ENV['DEBUG_OPTIMAL_RECIPE_GENERATOR']

  def self.define_debug_method(method_name, debug_implementation, non_debug_implementation)
    if debug
      define_singleton_method(method_name, &debug_implementation)
    else
      define_singleton_method(method_name, &non_debug_implementation)
    end
  end

  define_debug_method :round,
    -> (number) { number.round(4) },
    -> (number) { number }

  define_debug_method :rationalize,
    -> (number) { round(number).to_s.to_r },
    -> (number) { number }

  define_debug_method :multiply,
    -> (first, second) { rationalize(first) * rationalize(second) },
    -> (first, second) { first * second }

  define_debug_method :divide,
    -> (numerator, denominator) {
      Rational(rationalize(numerator), rationalize(denominator))
    },
    -> (numerator, denominator) {
      numerator.to_f / denominator
    }

  def self.generate(options = {})
    new(options).generate
  end

  include BenchmarkingHelpers

  attr_reader :nutrient_profile, :ingredients, :nutrients, :recipe

  delegate :min_value_for_nutrient, :max_value_for_nutrient,
    to: :nutrient_profile

  def initialize(nutrient_profile:, ingredients:, nutrient_names:)
    @nutrient_profile = build_nutrient_profile(nutrient_profile)
    @nutrient_names = nutrient_names
    @nutrients = build_nutrients(@nutrient_profile)
    @ingredients = build_ingredients(@nutrient_profile, ingredients)
    @objective_coefficients = build_objective_coefficients
    @constraints = build_constraints

    if @ingredients.empty?
      raise Error, "There aren't any ingredients, add some first!"
    end

    #pp objective_coefficients: objective_coefficients,
       #constraints: constraints
  end

  def generate
    simplex_problem = build_simplex_problem
    solution = solve_simplex(simplex_problem)
    Recipe.new(
      nutrient_profile: nutrient_profile,
      ingredients: ingredients,
      nutrients: nutrients,
      ingredient_amounts: solution
    )
  rescue SimplexWrapper::UnsolvableProblem
    nil
  end

  private

  attr_reader :nutrient_names, :objective_coefficients, :constraints,
    :simplex_problem

  def build_simplex_problem
    problem = SimplexWrapper.maximization_problem do |p|
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
    ingredients.map do |ingredient|
      # ingredient.average_nutrient_completeness_score
      ingredient.normalized_cost
    end
  end

  def build_constraints
    nutrients.inject([]) do |constraints, nutrient|
      coefficients = nutrient.ingredient_values
      min_value = OptimalRecipeGenerator.rationalize(nutrient.min_value)
      max_value = OptimalRecipeGenerator.rationalize(nutrient.max_value)

      if max_value.to_f > 0
        constraints << {
          coefficients: coefficients,
          range: [nil, max_value]
        }
      else
        puts "Skipping #{nutrient.name} since its max_value is 0"
      end

      constraints
    end
  end

  def solve_simplex(simplex_problem)
    measure('solve simplex') { simplex_problem.solve }
  end

  def normalized_nutrient_value_totals_by_name
    totals_by_nutrient_name = Hash.new(0)

    ingredients.each do |ingredient|
      nutrients.each_with_index do |nutrient, index|
        totals_by_nutrient_name[nutrient.name] +=
          ingredient.normalized_value_for_nutrient(nutrient.name)
      end
    end

    #pp totals_by_nutrient_name: totals_by_nutrient_name

    totals_by_nutrient_name
  end

  def build_nutrient_profile(nutrient_profile)
    NutrientProfile.new(nutrient_profile)
  end

  def build_ingredients(nutrient_profile, ingredients)
    ingredients.
      map do |ingredient|
        Ingredient.new(
          optimal_recipe_generator: self,
          nutrient_profile: nutrient_profile,
          ingredient: ingredient
        )
      end.
      reject do |ingredient|
        ingredient.container_size == 0 || ingredient.serving_size == 0
      end
  end

  def build_nutrients(nutrient_profile)
    nutrient_names.map do |nutrient_name|
      Nutrient.new(
        optimal_recipe_generator: self,
        name: nutrient_name
      )
    end
  end

  class NutrientProfile < SimpleDelegator
    def min_value_for_nutrient(nutrient)
      min = min_nutrient_collection.__send__(nutrient.name)

      if min
        OptimalRecipeGenerator.rationalize(min)
      end
    end

    def max_value_for_nutrient(nutrient)
      max = max_nutrient_collection.__send__(nutrient.name)

      if max
        OptimalRecipeGenerator.rationalize(max)
      end
    end
  end

  class Ingredient < SimpleDelegator
    attr_reader :cost, :container_size, :serving_size

    def initialize(optimal_recipe_generator:, nutrient_profile:, ingredient:)
      @optimal_recipe_generator = optimal_recipe_generator
      @nutrient_profile = nutrient_profile

      super(ingredient)

      @cost = ingredient.cost.to_f
      @container_size = ingredient.container_size.to_i
      @serving_size = ingredient.serving_size.to_f

      if @container_size == 0
        warn "Container size for #{name} is 0, ignoring"
      end

      if @serving_size == 0
        warn "Serving size for #{name} is 0, ignoring"
      end

      @values_by_nutrient_name = nutrients.inject({}) do |hash, nutrient|
        value = nutrient_collection.__send__(nutrient.name) || 0
        hash[nutrient.name] = OptimalRecipeGenerator.rationalize(value)
        hash
      end
    end

    def value_for_nutrient(nutrient)
      values_by_nutrient_name[nutrient.name]
    end

    def normalized_value_for_nutrient(nutrient)
      OptimalRecipeGenerator.divide(value_for_nutrient(nutrient), serving_size)
    end

    def normalized_cost
      OptimalRecipeGenerator.divide(cost, container_size)
    end

    def completeness_score_for_nutrient(nutrient)
      value = value_for_nutrient(nutrient)
      max_value = nutrient.max_value

      if max_value
        if max_value == 0
          Float::INFINITY
        else
          OptimalRecipeGenerator.divide(value, max_value)
        end
      else
        0
      end
    end

    def average_nutrient_completeness_score
      values = nutrients.
        map { |nutrient| completeness_score_for_nutrient(nutrient) }.
        reject { |value| value.to_f.infinite? }

      if values.size == 0
        0
      else
        OptimalRecipeGenerator.divide(values.sum, values.size)
      end
    end

    private

    attr_reader :optimal_recipe_generator, :nutrient_profile,
      :values_by_nutrient_name

    delegate :nutrients, to: :optimal_recipe_generator
  end

  class Nutrient
    attr_reader :name, :min_value, :max_value, :ingredient_values

    def initialize(optimal_recipe_generator:, name:)
      @optimal_recipe_generator = optimal_recipe_generator
      @name = name
      @min_value, @max_value = determine_min_and_max_value
    end

    def humanized_name
      name.to_s.humanize
    end

    def ingredient_values
      ingredients.map do |ingredient|
        ingredient.normalized_value_for_nutrient(self)
      end
    end

    private

    attr_reader :optimal_recipe_generator

    delegate :ingredients, to: :optimal_recipe_generator

    def determine_min_and_max_value
      min_value = optimal_recipe_generator.min_value_for_nutrient(self)
      max_value = optimal_recipe_generator.max_value_for_nutrient(self)

      # Some nutrient profiles are not configured correctly
      if max_value.to_f > 0 && min_value.to_f > max_value.to_f
        raise Error, "Min value for #{name} is greater than max value! Please fix your nutrient profile and try again."
      end

      [min_value, max_value]
    end
  end

  class Recipe
    attr_reader :nutrient_profile, :ingredients, :nutrients

    def initialize(nutrient_profile:, ingredients:, nutrients:, ingredient_amounts:)
      @nutrient_profile = nutrient_profile
      #pp ingredient_amounts: ingredient_amounts

      @ingredients = ingredients.zip(ingredient_amounts).map do |ingredient, ingredient_amount|
        RecipeIngredient.new(ingredient).tap do |recipe_ingredient|
          recipe_ingredient.daily_serving = ingredient_amount.to_i
          #pp ingredient_name: recipe_ingredient.name,
             #daily_serving: recipe_ingredient.daily_serving
        end
      end

      @nutrients = nutrients
    end

    def ingredients_with_daily_servings
      ingredients.select { |ingredient| ingredient.daily_serving > 0 }
    end

    def total_cost
      ingredients.sum(&:cost)
    end

    def total_multiplied_value_for_nutrient(nutrient)
      ingredients.sum do |ingredient|
        ingredient.multiplied_value_for_nutrient(nutrient)
      end
    end

    def total_multiplied_cost
      ingredients.sum(&:multiplied_cost)
    end

    def min_completeness_score_for_nutrient(nutrient)
      total = total_multiplied_value_for_nutrient(nutrient)
      min = nutrient.min_value

      if min
        if min == 0
          Float::INFINITY
        else
          OptimalRecipeGenerator.divide(total, min)
        end
      end
    end

    def max_completeness_score_for_nutrient(nutrient)
      total = total_multiplied_value_for_nutrient(nutrient)
      max = nutrient.max_value

      if max
        if max == 0
          Float::INFINITY
        else
          OptimalRecipeGenerator.divide(total, max)
        end
      end
    end
  end

  class RecipeIngredient < SimpleDelegator
    def initialize(ingredient)
      super(ingredient)

      @daily_serving = 0
    end

    attr_accessor :daily_serving

    def multiplied_value_for_nutrient(nutrient)
      OptimalRecipeGenerator.multiply(daily_serving, normalized_value_for_nutrient(nutrient))
    end

    def multiplied_cost
      OptimalRecipeGenerator.multiply(daily_serving, normalized_cost)
    end

    def days_per_serving
      OptimalRecipeGenerator.divide(container_size, daily_serving)
    end

    def percentage_of_container
      OptimalRecipeGenerator.divide(daily_serving, container_size)
    end
  end
end
