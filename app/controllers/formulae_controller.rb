class FormulaeController < ApplicationController
  def index
    nutrient_profile = NutrientProfile.
      includes(:min_nutrient_collection, :max_nutrient_collection).
      find(params[:nutrient_profile_id])

    ingredients = Ingredient.includes(:nutrient_collection)

    formula = FormulaGenerator.call(
      nutrient_profile: nutrient_profile,
      ingredients: ingredients
    )
    @formulae = [formula]
  end
end
