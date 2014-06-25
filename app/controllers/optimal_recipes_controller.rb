class OptimalRecipesController < ApplicationController
  def show
    @nutrient_names = NutrientCollection.modifiable_attribute_names

    nutrient_profile = NutrientProfile.
      includes(:min_nutrient_collection, :max_nutrient_collection).
      find(params[:nutrient_profile_id])

    ingredients = Ingredient.includes(:nutrient_collection)

    @recipe = OptimalRecipeGenerator.generate(
      nutrient_profile: nutrient_profile,
      ingredients: ingredients,
      nutrient_names: @nutrient_names
    )
  end
end
