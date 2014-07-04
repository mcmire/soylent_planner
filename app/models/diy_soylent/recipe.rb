module DiySoylent
  class Recipe
    def self.fetch(url, options = {})
      json_url = url + '/json'
      params = {}

      if options[:nutrient_profile_id]
        params[:nutrientProfile] = options[:nutrient_profile_id]
      end

      body = make_request(json_url, params)
      data = JSON.parse(body)

      new(data)
    end

    def self.make_request(url, params)
      body = nil

      elapsed_time = Benchmark.realtime do
        body = HTTP.get(url, params: params).to_s
      end

      Rails.logger.debug "Time to fetch recipe: #{elapsed_time} seconds"

      body
    end

    def self.request_cache
      @_request_cache ||= {}
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
