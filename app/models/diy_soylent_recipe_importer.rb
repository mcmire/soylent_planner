class DiySoylentRecipeImporter
  attr_reader :new_ingredients, :existing_ingredients, :valid_ingredients,
    :invalid_ingredients

  def initialize(recipe_url)
    @recipe_url = recipe_url + '/json'
    @ingredients = []
  end

  def call
    @new_ingredients, @existing_ingredients = new_and_existing_ingredients
    pp new_ingredients
    new_ingredients.each(&:save)
    @valid_ingredients, @invalid_ingredients = valid_and_invalid_ingredients
  end

  def failed?
    !new_ingredients.empty? && valid_ingredients.empty?
  end

  private

  attr_reader :recipe_url

  def built_ingredients
    @_built_ingredients ||= DiySoylent::Recipe.fetch(recipe_url).ingredients
  end

  def new_and_existing_ingredients
    built_ingredients.partition do |ingredient|
      !Ingredient.exists?(digest: ingredient.calculated_digest)
    end
  end

  def valid_and_invalid_ingredients
    new_ingredients.partition do |ingredient|
      ingredient.errors.empty?
    end
  end
end
