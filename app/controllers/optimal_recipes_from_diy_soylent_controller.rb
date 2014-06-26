class OptimalRecipesFromDiySoylentController < ApplicationController
  def new
    @recipe_url = params.fetch(:recipe_url) do
      'http://diy.soylent.me/recipes/all-ingredients'
    end
  end

  def show
    @recipe_url = params.fetch(:recipe_url)

    @nutrient_names = NutrientCollection.modifiable_attribute_names

    recipe_url = params[:recipe_url] + '/json'

    if recipe_url.present?
      recipe = DiySoylent::Recipe.fetch(recipe_url)

      @recipe = OptimalRecipeGenerator.generate(
        nutrient_profile: recipe.nutrient_profile,
        ingredients: recipe.ingredients,
        nutrient_names: @nutrient_names
      )

      render template: 'optimal_recipes/show'
    else
      flash.now[:danger] = "Missing recipe URL."
      render :new
    end
  end
end
