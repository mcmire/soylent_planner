require 'delegate'

class IngredientPresenter < SimpleDelegator
  include AttributePresenterHelpers

  def initialize(ingredient, nutrient_profile: nil)
    super(ingredient)
    @nutrient_profile = nutrient_profile
  end

  def nutrient_collection
    @_nutrient_collection ||= NutrientCollectionPresenter.new(super,
      nutrient_profile: @nutrient_profile
    )
  end

  def present_nutrient_with_unit(attribute_name)
    nutrient_collection.present_with_unit(attribute_name)
  end

  def human_attribute_name(attribute_name)
    Ingredient.human_attribute_name(attribute_name)
  end
end
