module DiySoylent
  class Ingredient
    EXCLUDED_ATTRIBUTES = [
      :_id,
      :id,
      :currency,
      :asin,
      :usdaId,
      :ingredientId,
      :persistedAsin
    ]
    INGREDIENT_ATTRIBUTES = [
      :name,
      :container_size,
      :form,
      :source,
      :unit
    ]
    ATTRIBUTE_MAPPING = {
      ingredient: {
        amount: :daily_serving,
        item_cost: :cost,
        serving: :serving_size,
        url: :link
      },

      nutrient_collection: {
        carbs: :carbohydrates,
        fat: :total_fat,
        fiber: :total_fiber,
        maganese: :manganese,
        panthothenic: :pantothenic_acid,
        selinium: :selenium
      }
    }

    attr_reader :ingredient_attributes, :nutrient_collection_attributes

    def initialize(attributes = {})
      @ingredient_attributes = {}
      @nutrient_collection_attributes = {}
      assign_attributes(attributes)
    end

    def form=(value)
      @ingredient_attributes[:form] = value.downcase
    end

    private

    def assign_attributes(attributes)
      attributes_to_assign(attributes).each do |name, value|
        if respond_to?("#{name}=", true)
          __send__("#{name}=", value)
        elsif ATTRIBUTE_MAPPING[:ingredient].key?(name)
          name = ATTRIBUTE_MAPPING[:ingredient][name]
          @ingredient_attributes[name] = value
        elsif ATTRIBUTE_MAPPING[:nutrient_collection].key?(name)
          name = ATTRIBUTE_MAPPING[:nutrient_collection][name]
          @nutrient_collection_attributes[name] = value
        elsif INGREDIENT_ATTRIBUTES.include?(name)
          @ingredient_attributes[name] = value
        else
          @nutrient_collection_attributes[name] = value
        end
      end
    end

    def attributes_to_assign(attributes)
      attributes.inject({}) do |hash, (key, value)|
        key = key.gsub('-', '_').to_sym

        if !EXCLUDED_ATTRIBUTES.include?(key) && (!value.is_a?(Fixnum) || value > 0)
          hash[key] = value
        end

        hash
      end
    end
  end
end
