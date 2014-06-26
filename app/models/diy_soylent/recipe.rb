module DiySoylent
  class Recipe
    def self.fetch(url)
      data = JSON.parse(HTTP.get(url).to_s)
      new(data)
    end

    def initialize(data)
      @data = data
    end

    def ingredients
      @_ingredients ||=
        data['ingredients'].map do |remote_ingredient|
          ingredient_from(remote_ingredient)
        end
    end

    def nutrient_profile
      @_nutrient_profile ||=
        DiySoylent::NutrientProfile.new(data['nutrientTargets']).
          to_soylent_planner_nutrient_profile
    end

    private

    attr_reader :data

    def ingredient_from(remote_ingredient)
      DiySoylent::Ingredient.new(remote_ingredient).
        to_soylent_planner_ingredient
    end
  end
end
