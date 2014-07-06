class UsdaFood < UsdaNutrientDatabase::Food
  SERVING_SIZE = 100

  def self.selected
    query = <<-EOT
      food_group_code NOT IN (
        '0300', '0500', '0700', '1000', '1300', '1500', '1700', '1800', '1900',
        '2100', '2200', '2500', '3500', '3600'
      ) AND
      long_description NOT ILIKE '%canned%' AND
      long_description NOT ILIKE '%cooked%' AND
      long_description NOT ILIKE '%noodles%' AND
      long_description NOT ILIKE '%macaroni%' AND
      long_description NOT ILIKE '%pasta%' AND
      long_description NOT ILIKE '%spaghetti%' AND
      long_description NOT ILIKE '%frozen%' AND
      long_description NOT ILIKE '%tea, instant%' AND
      long_description NOT ILIKE '%salad dressing%' AND
      long_description NOT ILIKE '%spices%' AND
      long_description NOT ILIKE '%carbonated beverage%' AND
      long_description NOT ILIKE '%coffee substitute%' AND
      long_description NOT ILIKE '%fish%' AND
      manufacturer_name = ''
    EOT
    where(query)
  end

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
