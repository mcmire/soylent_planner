class UsdaFood < UsdaNutrientDatabase::Food
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

  private

  def ingredient_attribute_builder
    @_ingredient_attribute_builder ||=
      IngredientAttributeBuilder.new(self)
  end
end
