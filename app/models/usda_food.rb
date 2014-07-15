class UsdaFood < UsdaNutrientDatabase::Food
  SERVING_SIZE = 100

  def self.selected
    words_to_exclude = [
      'canned', 'cooked', 'noodles', 'macaroni', 'pasta', 'spaghetti', 'frozen',
      'tea', 'salad dressing', 'spices', 'carbonated', 'coffee', 'fish',
      'stewed', 'grilled', 'alcohol', 'microwaved', 'ice cream', 'mushrooms',
      'vinegar', 'vanilla extract', 'tomato chili sauce', 'potato salad',
      'soup', 'lentils, raw', 'nectarines', 'beans%raw', 'baked', 'pickled',
      'jicama', 'papad'
    ]

    query = <<-EOT
      food_group_code NOT IN (
        '0300', '0500', '0700', '1000', '1300', '1500', '1700', '1800', '1900',
        '2100', '2200', '2500', '3500', '3600'
      ) AND
      manufacturer_name = ''
    EOT

    query << ' AND ' + words_to_exclude.map do |word|
      "long_description NOT ILIKE '%#{word}%'"
    end.join(' AND ')

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
    Ingredient.new do |ingredient|
      ingredient.name = long_description
      ingredient.container_size = 1000
      ingredient.cost = 100
      ingredient.serving_size = SERVING_SIZE
      ingredient.build_nutrient_collection(ingredient_attributes)
    end
  end

  private

  def ingredient_attribute_builder
    @_ingredient_attribute_builder ||= IngredientAttributeBuilder.new(self)
  end
end
