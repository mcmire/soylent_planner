class UsdaFood < UsdaNutrientDatabase::Food
  NUTRIENT_NUMBERS_BY_INGREDIENT_ATTRIBUTE = {
    calories: 268,
    carbohydrates: 205,
    protein: 203,
    total_fat: 204,
    saturated_fat: 606,
    monounsaturated_fat: 645,
    polyunsaturated_fat: 646,
    omega_3: [851, 852, 629, 631, 621],
    omega_6: [675, 685, 672, 853, 855],
    total_fiber: 291,
    cholesterol: 601,
    calcium: 301,
    copper: 312,
    iron: 303,
    magnesium: 304,
    manganese: 315,
    phosphorus: 305,
    potassium: 306,
    selenium: 317,
    sodium: 307,
    zinc: 309,
    vitamin_a: 318,
    vitamin_b6: 415,
    vitamin_b12: 418,
    vitamin_c: 401,
    vitamin_e: 323,
    vitamin_k: 430,
    thiamin: 404,
    riboflavin: 405,
    niacin: 406,
    folate: 417,
    pantothenic_acid: 410,
    choline: 421
  }

  include PgSearch

  pg_search_scope :search_by_long_description,
    against: :long_description,
    ranked_by: ':trigram'

  def ingredient_attributes
    NUTRIENT_NUMBERS_BY_INGREDIENT_ATTRIBUTE.
      inject({}) do |hash, (attribute_name, nutrient_numbers)|
        nutrient_numbers = Array(nutrient_numbers)
        hash[attribute_name] = nutrient_numbers.
          map { |nutrient_number|
            foods_nutrients_by_nutrient_number[nutrient_number.to_s]
          }.
          compact.
          sum(&:nutrient_value)
        hash
      end
  end

  def foods_nutrients_by_nutrient_number
    @_foods_nutrients_by_nutrient_number ||=
      foods_nutrients.includes(:nutrient).index_by(&:nutrient_number)
  end
end
