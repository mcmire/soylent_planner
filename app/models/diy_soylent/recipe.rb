module DiySoylent
  class Recipe
    def self.fetch(url, options = {})
      json_url = url + '/json'
      params = {}

      if options[:nutrient_profile_id]
        params[:nutrientProfile] = options[:nutrient_profile_id]
      end

      body = HTTP.get(json_url, params: params).to_s
      data = JSON.parse(body)

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
