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
      flash[:success] = 'Nutrient profile created'
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
      flash[:success] = 'Nutrient profile updated'
      redirect_to action: :index
    else
      render :new
    end
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
      nutrient_collection_attributes: [
        :id,
        :calories,
        :carbohydrates,
        :protein,
        :total_fat,
        :saturated_fat,
        :monounsaturated_fat,
        :polyunsaturated_fat,
        :omega_3,
        :omega_6,
        :total_fiber,
        :soluble_fiber,
        :insoluble_fiber,
        :cholesterol,
        :calcium,
        :chloride,
        :chromium,
        :copper,
        :iodine,
        :iron,
        :magnesium,
        :manganese,
        :molybdenum,
        :phosphorus,
        :potassium,
        :selenium,
        :sodium,
        :sulfur,
        :zinc,
        :vitamin_a,
        :vitamin_b6,
        :vitamin_b12,
        :vitamin_c,
        :vitamin_e,
        :vitamin_k,
        :thiamin,
        :riboflavin,
        :niacin,
        :folate,
        :pantothenic_acid,
        :biotin,
        :choline,
      ]
    )
  end
end
