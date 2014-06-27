module DiySoylent
  class NutrientProfile
    EXCLUDED_ATTRIBUTES = [
      :__v,
      :_id,
      :author,
      :authorId,
      :createdAt,
      :hidden,
      :rating,
      :updatedAt,
      :reviews
    ]
    ATTRIBUTE_MAPPING = {
      carbs: :carbohydrates,
      fat: :total_fat,
      fiber: :total_fiber,
      maganese: :manganese,
      panthothenic: :pantothenic_acid,
      selinium: :selenium
    }

    def initialize(attributes = {})
      @min_nutrient_collection_attributes = {}
      @max_nutrient_collection_attributes = {}

      assign_attributes(attributes)
    end

    def to_soylent_planner_nutrient_profile
      ::NutrientProfile.new.tap do |nutrient_profile|
        nutrient_profile.build_min_nutrient_collection(
          min_nutrient_collection_attributes
        )
        nutrient_profile.build_max_nutrient_collection(
          max_nutrient_collection_attributes
        )
      end
    end

    private

    attr_reader :min_nutrient_collection_attributes,
      :max_nutrient_collection_attributes

    def assign_attributes(attributes)
      attributes.each do |key, value|
        next if key == 'name' or EXCLUDED_ATTRIBUTES.include?(key.to_sym)

        key = key.gsub('-', '_')

        if key.end_with?('_max')
          nutrient_name = key[/^(.+)_max$/, 1].to_sym
          nutrient_collection_attributes =
            @max_nutrient_collection_attributes
        else
          nutrient_name = key.to_sym
          nutrient_collection_attributes =
            @min_nutrient_collection_attributes
        end

        if ATTRIBUTE_MAPPING.key?(nutrient_name)
          nutrient_name = ATTRIBUTE_MAPPING[nutrient_name]
        end

        nutrient_collection_attributes[nutrient_name] = value
      end
    end
  end
end
