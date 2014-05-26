class DiySoylentRecipeImporter
  attr_reader :new_ingredients, :existing_ingredients, :valid_ingredients, :invalid_ingredients

  def initialize(url)
    @url = url + '/json'
    @ingredients = []
  end

  def call
    @new_ingredients, @existing_ingredients = new_and_existing_ingredients
    new_ingredients.each(&:save)
    @valid_ingredients, @invalid_ingredients = valid_and_invalid_ingredients
  end

  def failed?
    valid_ingredients.empty?
  end

  private

  attr_reader :url

  def remote_recipe
    @_remote_recipe ||= JSON.parse(HTTP.get(@url).to_s)
  end

  def built_ingredients
    @_built_ingredients ||=
      remote_recipe['ingredients'].map do |remote_ingredient|
        build_ingredient_from(remote_ingredient)
      end
  end

  def build_ingredient_from(remote_ingredient)
    ingredient = Ingredient.new
    nutrient_collection = ingredient.build_nutrient_collection
    diy_soylent_ingredient = DiySoylent::Ingredient.new(remote_ingredient)
    ingredient.assign_attributes(
      diy_soylent_ingredient.ingredient_attributes
    )
    nutrient_collection.assign_attributes(
      diy_soylent_ingredient.nutrient_collection_attributes
    )
    ingredient
  end

  def new_and_existing_ingredients
    built_ingredients.partition do |ingredient|
      !Ingredient.exists?(name: ingredient.name)
    end
  end

  def valid_and_invalid_ingredients
    new_ingredients.partition do |ingredient|
      ingredient.errors.empty?
    end
  end
end
