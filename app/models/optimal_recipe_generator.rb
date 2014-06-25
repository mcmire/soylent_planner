# TODO: Can you also try an alternate approach, where you start with the
# ingredient that has the most of the first nutrient, add as much as we can for
# each nutrient, move to the next ingredient, add as much as we can for all
# nutrients, etc.? This is a greedy approach...

class OptimalRecipeGenerator
  PRECISION = 4
  #PRECISION = nil

  def self.precision
    PRECISION
  end

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

  delegate :min_value_for_nutrient, :max_value_for_nutrient,
    to: :nutrient_profile

  def initialize(nutrient_profile:, ingredients:, nutrient_names:)
    @nutrient_profile = build_nutrient_profile(nutrient_profile)
    @ingredients = build_ingredients(@nutrient_profile, ingredients)
    @nutrient_names = nutrient_names
    @nutrients = build_nutrients(@nutrient_profile, @ingredients)
    @objective_coefficients = build_objective_coefficients
    @constraints = build_constraints

    if @ingredients.empty?
      raise "There aren't any ingredients, add some first!"
    end

    #pp objective_coefficients: objective_coefficients,
       #constraints: constraints
  end

  def generate
    simplex_problem = build_simplex_problem
    solution = simplex_problem.solve
    Recipe.new(
      nutrient_profile: nutrient_profile,
      ingredients: ingredients,
      nutrients: nutrients,
      ingredient_amounts: solution
    )
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

    #problem.debug!

    problem
  end

  def build_objective_coefficients
    ingredients.map do |ingredient|
      ingredient.average_nutrient_completeness_score
    end
  end

  def build_constraints
    nutrients.inject([]) do |constraints, nutrient|
      coefficients = nutrient.ingredient_values
      min_value = nutrient.min_value.to_s.to_r
      max_value = nutrient.max_value.to_s.to_r

      if min_value.to_f > 0 && max_value.to_f > 0
        constraints << {
          coefficients: coefficients,
          range: [nil, max_value]
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

  def build_nutrients(nutrient_profile, ingredients)
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
        min.to_f.rationalize
      end
    end

    def max_value_for_nutrient(nutrient)
      max = max_nutrient_collection.__send__(nutrient.name)

      if max
        max.to_f.rationalize
      end
    end
  end

  class Ingredient < SimpleDelegator
    attr_reader :container_size, :serving_size

    def initialize(optimal_recipe_generator:, nutrient_profile:, ingredient:)
      @optimal_recipe_generator = optimal_recipe_generator
      @nutrient_profile = nutrient_profile

      super(ingredient)

      @container_size = ingredient.container_size.to_i
      @serving_size = ingredient.serving_size.to_i

      if cost.to_f == 0
        raise "Cost for #{name} is 0?"
      end

      if @container_size == 0
        warn "Container size for #{name} is 0, ignoring"
      end

      if @serving_size == 0
        warn "Serving size for #{name} is 0, ignoring"
      end
    end

    def value_for_nutrient(nutrient)
      (nutrient_collection.__send__(nutrient.name) || 0).to_f.rationalize
    end

    def normalized_value_for_nutrient(nutrient)
      normalized_value = Rational(value_for_nutrient(nutrient), serving_size)
      #puts "#{name} has #{value_for_nutrient(nutrient_name)} #{NutrientCollection.unit_for(nutrient_name)} of #{nutrient_name};\n  its container size is #{container_size} #{unit} which means the normalized value is #{normalized_value}"
      normalized_value
    end

    def normalized_cost
      normalized_cost = Rational(cost.to_f.rationalize, container_size)
      #puts "#{name} costs $#{cost};\n  its container size is #{container_size} #{unit} which means the normalized cost is $#{normalized_cost}"
      normalized_cost
    end

    def completeness_score_for_nutrient(nutrient)
      value = value_for_nutrient(nutrient)
      max_value = nutrient.max_value

      if value.to_i == 0 || max_value.to_i == 0
        0
      else
        Rational(value, max_value)
      end
    end

    def average_nutrient_completeness_score
      values = nutrients.map do |nutrient|
        completeness_score_for_nutrient(nutrient)
      end

      if values.size == 0
        0
      else
        Rational(values.sum, values.size)
      end
    end

    private

    attr_reader :optimal_recipe_generator, :nutrient_profile

    delegate :nutrients, to: :optimal_recipe_generator
  end

  class Nutrient
    attr_reader :name, :min_value, :max_value, :ingredient_values

    def initialize(optimal_recipe_generator:, name:)
      @optimal_recipe_generator = optimal_recipe_generator
      @name = name
    end

    def humanized_name
      name.to_s.humanize
    end

    def ingredient_values
      ingredients.map do |ingredient|
        ingredient.normalized_value_for_nutrient(self)
      end
    end

    def min_value
      optimal_recipe_generator.min_value_for_nutrient(self)
    end

    def max_value
      optimal_recipe_generator.max_value_for_nutrient(self)
    end

    private

    attr_reader :optimal_recipe_generator

    delegate :ingredients, to: :optimal_recipe_generator
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

    def completeness_score_for_nutrient(nutrient)
      total = total_multiplied_value_for_nutrient(nutrient)
      max = nutrient_profile.max_value_for_nutrient(nutrient)

      if max
        if max == 0
          0
        else
          Rational(total, max)
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
      daily_serving.rationalize * normalized_value_for_nutrient(nutrient)
    end

    def multiplied_cost
      daily_serving.rationalize * normalized_cost
    end
  end
end
