require 'matrix'

class OptimalRecipeGenerator
  def self.call(options = {})
    new(options).call
  end

  def initialize(nutrient_profile:, ingredients:)
    @nutrient_profile = build_nutrient_profile(nutrient_profile)
    @ingredients = build_ingredients(ingredients)
    @nutrients = build_nutrients(@nutrient_profile, @ingredients)
    @tableau = Tableau.new([build_maximization_row] + build_constraint_rows)
  end

  def call
    solution = tableau.maximize
    pp solution: solution
    solution
  end

  private

  attr_reader :nutrient_profile, :ingredients, :nutrients, :tableau

  def build_maximization_row
    normalized_ingredient_costs = ingredients.map do |ingredient|
      -ingredient.normalized_cost
    end

    Row.new(
      lhs: normalized_ingredient_costs,
      rhs: 0,
      slack_variable: -1
    )
  end

  def build_constraint_rows
    rows = []

    nutrients[0..3].each do |nutrient|
      pp nutrient_name: nutrient.name
      rows << Row.new(
        lhs: nutrient.ingredient_values,
        rhs: nutrient.min_value,
        slack_variable: -1
      )
      rows << Row.new(
        lhs: nutrient.ingredient_values,
        rhs: nutrient.max_value,
        slack_variable: 1
      )
    end

    rows
  end

  def build_nutrient_profile(nutrient_profile)
    NutrientProfile.new(nutrient_profile)
  end

  def build_ingredients(ingredients)
    ingredients[0..2].map { |ingredient| Ingredient.new(ingredient) }
  end

  def build_nutrients(nutrient_profile, ingredients)
    NutrientCollection.modifiable_attribute_names[0..3].map do |nutrient_name|
      ingredient_values = ingredients[0..2].map do |ingredient|
        value = ingredient.normalized_value_for_nutrient(nutrient_name)
        pp ingredient_name: ingredient.name,
           nutrient_name: nutrient_name,
           value: value
        value
      end

      Nutrient.new(
        name: nutrient_name,
        min_value: nutrient_profile.min_value_for_nutrient(nutrient_name),
        max_value: nutrient_profile.max_value_for_nutrient(nutrient_name),
        ingredient_values: ingredient_values
      )
    end
  end

  class Tableau
    def initialize(rows)
      @rows = rows
      @number_of_slack_variables = calculate_number_of_slack_variables
      @row_length = calculate_row_length
      @simplex_matrix = Matrix[*build_tableau].extend(Simplex)
    end

    def maximize
      simplex_matrix.maximize
    end

    private

    attr_reader :rows, :number_of_slack_variables, :row_length, :simplex_matrix

    def build_tableau
      rows.map.with_index do |row, index|
        new_row = Array.new(row_length, 0)
        new_row[0...row.lhs.size] = row.lhs
        new_row[row.lhs.size + index] = row.slack_variable
        new_row[-1] = row.rhs
        new_row
      end.tap do |tableau|
        pp tableau: tableau
      end
    end

    def calculate_number_of_slack_variables
      rows.select(&:has_slack_variable?).size
    end

    def calculate_row_length
      rows.
        map { |row| row.lhs.size + number_of_slack_variables + 1 }.
        max
    end
  end

  class Row
    attr_reader :lhs, :rhs, :slack_variable

    def initialize(lhs:, rhs:, slack_variable:)
      @lhs = lhs
      @rhs = rhs
      @slack_variable = slack_variable
    end

    def has_slack_variable?
      !!slack_variable
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
      (value_for_nutrient(nutrient_name) / serving_size).to_f
    end

    def normalized_cost
      (cost / container_size).to_f
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
end
