class OptimalRecipesFromUsdaDatabaseController < ApplicationController
  def new
    @recipe_url = params.fetch(:recipe_url) do
      'http://diy.soylent.me/recipes/all-ingredients'
    end
    @nutrient_profile_id = params[:nutrient_profile_id]
  end

  def show
    @recipe_url = params[:recipe_url]
    @nutrient_profile_id = params[:nutrient_profile_id]
    @nutrient_names = ::NutrientCollection.modifiable_attribute_names
    recipe_generator = OptimalRecipeGeneratorFromUsdaDatabase.new(
      @recipe_url,
      @nutrient_profile_id,
      @nutrient_names
    )

    if @recipe_url.present?
      @recipe = recipe_generator.generate
      render template: 'optimal_recipes/show'
    else
      flash[:danger] = "Missing recipe URL."
      redirect_to action: :new,
        recipe_url: @recipe_url,
        nutrient_profile_id: @nutrient_profile_id
    end
  end
end
