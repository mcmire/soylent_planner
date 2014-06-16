class OptimalRecipesController < ApplicationController
  def show
    nutrient_profile = NutrientProfile.
      includes(:min_nutrient_collection, :max_nutrient_collection).
      find(params[:nutrient_profile_id])

    ingredients = Ingredient.includes(:nutrient_collection)

    @recipe = OptimalRecipeGenerator.call(
      nutrient_profile: nutrient_profile,
      ingredients: ingredients
    )
  end
end
