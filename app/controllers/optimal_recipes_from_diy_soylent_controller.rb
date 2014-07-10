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
      flash[:danger] = "Missing recipe URL."
      redirect_to action: :new,
        recipe_url: @recipe_url,
        nutrient_profile_id: @nutrient_profile_id
    end
  rescue OptimalRecipeGenerator::Error => error
    flash[:danger] = error.message
    redirect_to action: :new,
      recipe_url: @recipe_url,
      nutrient_profile_id: @nutrient_profile_id
  rescue => error
    Rails.logger.debug "#{error.class}: #{error.message}"
    Rails.logger.debug error.backtrace.join("\n")

    flash[:danger] = "Hmm... seems there was a problem generating your recipe. Sorry about that."
    redirect_to action: :new,
      recipe_url: @recipe_url,
      nutrient_profile_id: @nutrient_profile_id
  end
end
