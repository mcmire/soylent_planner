class IngredientsController < ApplicationController
  def index
    @ingredients = Ingredient.order('LOWER(name)')
  end

  def new
    @ingredient = Ingredient.new
    @ingredient.build_nutrient_collection
  end

  def new_from_usda_food
    usda_food = UsdaFood.find(params[:usda_food_id])
    @ingredient = Ingredient.new_from_usda_food(usda_food)
    render :new
  end

  def create
    @ingredient = Ingredient.new(ingredient_params)

    if @ingredient.save
      flash[:success] = 'Ingredient created successfully.'
      redirect_to action: :index
    else
      render :new
    end
  end

  def edit
    @ingredient = Ingredient.find(params[:id])
  end

  def update
    @ingredient = Ingredient.find(params[:id])

    @ingredient.assign_attributes(ingredient_params)

    if @ingredient.save
      flash[:success] = 'Ingredient updated successfully.'
      redirect_to action: :index
    else
      render :new
    end
  end

  def destroy
    Ingredient.destroy(params[:id])
    head :ok
  end

  private

  def ingredient_params
    params.require(:ingredient).permit(
      :name,
      :form,
      :unit,
      :container_size,
      :cost,
      :source,
      :link,
      :daily_serving,
      :serving_size,
      nutrient_collection_attributes: nutrient_collection_attributes
    )
  end

  def nutrient_collection_attributes
    NutrientCollection.modifiable_attribute_names + [:id]
  end
end
