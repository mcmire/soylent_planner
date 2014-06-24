class OptimalRecipesController < ApplicationController
  def show
    @nutrient_names = NutrientCollection.modifiable_attribute_names[0...5]

    nutrient_profile = NutrientProfile.
      includes(:min_nutrient_collection, :max_nutrient_collection).
      find(params[:nutrient_profile_id])

    ingredients = Ingredient.includes(:nutrient_collection)
    #ingredients = Ingredient.
      #where(id: [252]).
      #includes(:nutrient_collection)

    @recipe = OptimalRecipeGenerator.generate(
      nutrient_profile: nutrient_profile,
      ingredients: ingredients,
      nutrient_names: @nutrient_names
    )
  end
end
