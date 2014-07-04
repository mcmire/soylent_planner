class UsdaFood < UsdaNutrientDatabase::Food
  SERVING_SIZE = 100

  include PgSearch

  pg_search_scope :search_by_long_description,
    against: :long_description,
    ranked_by: ':trigram'

  def eager_foods_nutrients
    foods_nutrients.includes(:nutrient)
  end

  def ingredient_attributes
    ingredient_attribute_builder.call
  end

  def to_soylent_planner_ingredient
    Ingredient.new.tap do |ingredient|
      ingredient.name = long_description
      ingredient.container_size = 1000
      ingredient.cost = 100
      ingredient.serving_size = SERVING_SIZE
      ingredient.build_nutrient_collection(ingredient_attributes)
    end
  end

  private

  def ingredient_attribute_builder
    @_ingredient_attribute_builder ||=
      IngredientAttributeBuilder.new(self)
  end
end
