class OptimalRecipesFromDiySoylentController < ApplicationController
  def new
    @recipe_url = params.fetch(:recipe_url) do
      'http://diy.soylent.me/recipes/all-ingredients'
    end
    @nutrient_profile_id = params[:nutrient_profile_id]
  end

  def show
    @recipe_url = params[:recipe_url]
    @nutrient_profile_id = params[:nutrient_profile_id]
    @nutrient_names = NutrientCollection.modifiable_attribute_names

    if @recipe_url.present?
      diy_soylent_recipe = DiySoylent::Recipe.fetch(@recipe_url,
        nutrient_profile_id: @nutrient_profile_id
      )

      @recipe = OptimalRecipeGenerator.generate(
        nutrient_profile: diy_soylent_recipe.nutrient_profile,
        ingredients: diy_soylent_recipe.ingredients,
        nutrient_names: @nutrient_names
      )

      render template: 'optimal_recipes/show'
    else
      flash.now[:danger] = "Missing recipe URL."
      render :new
    end
  end
end
