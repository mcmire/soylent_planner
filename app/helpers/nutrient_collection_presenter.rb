require 'delegate'

class NutrientCollectionPresenter < SimpleDelegator
  include AttributePresenterHelpers

  def initialize(nutrient_collection, nutrient_profile: nil)
    super(nutrient_collection)
    @nutrient_profile = nutrient_profile
  end

  def human_attribute_name(attribute_name)
    NutrientCollection.human_attribute_name(attribute_name)
  end

  def present_with_unit(attribute_name)
    unit = NutrientCollection.unit_for(attribute_name)
    value = public_send(attribute_name)

    if value && value > 0
      value_parts = [ value, unit ]

      if @nutrient_profile
        min_percentage = percentage_of_min(attribute_name, value)
        max_percentage = percentage_of_max(attribute_name, value)
        min_and_max_percentage = []

        if min_percentage
          min_and_max_percentage << "#{min_percentage.round(2)}% of min"
        end

        if max_percentage
          min_and_max_percentage << "#{max_percentage.round(2)}% of max"
        end

        if min_and_max_percentage.any?
          value_parts << content_tag(:span,
            "(#{min_and_max_percentage.join(' / ')})",
            class: 'percentage-of-goal'
          )
        end
      end

      value_with_unit = value_parts.join(" ").html_safe

      present_with_label(attribute_name, value_with_unit)
    end
  end

  def percentage_of_min(attribute_name, value)
    min_value = min_value_for(attribute_name)

    if min_value && min_value > 0
      (value.to_f / min_value) * 100
    end
  end

  def percentage_of_max(attribute_name, value)
    max_value = max_value_for(attribute_name)

    if max_value && max_value > 0
      (value.to_f / max_value) * 100
    end
  end

  def min_value_for(attribute_name)
    @nutrient_profile.min_nutrient_collection.public_send(attribute_name)
  end

  def max_value_for(attribute_name)
    @nutrient_profile.max_nutrient_collection.public_send(attribute_name)
  end
end
