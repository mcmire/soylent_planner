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
      key = ActiveSupport::JSON.encode(url: url, params: params)

      if request_cache.key?(key)
        puts "Pulling data out of cache"
      else
        puts "Performing request"
      end

      request_cache[key] ||= HTTP.get(url, params: params).to_s
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
