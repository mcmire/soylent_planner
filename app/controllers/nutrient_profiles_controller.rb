class NutrientProfilesController < ApplicationController
  def index
    @nutrient_profiles = NutrientProfile.all
  end

  def new
    @nutrient_profile = NutrientProfile.new
    @nutrient_profile.build_nutrient_collection
  end

  def create
    @nutrient_profile = NutrientProfile.new(nutrient_profile_params)

    if @nutrient_profile.save
      flash[:success] = 'Nutrient profile created successfully.'
      redirect_to action: :index
    else
      render :new
    end
  end

  def edit
    @nutrient_profile = NutrientProfile.find(params[:id])
  end

  def update
    @nutrient_profile = NutrientProfile.find(params[:id])

    @nutrient_profile.assign_attributes(nutrient_profile_params)

    if @nutrient_profile.save
      flash[:success] = 'Nutrient profile updated successfully.'
      redirect_to action: :index
    else
      render :edit
    end
  end

  private

  def nutrient_profile_params
    params.require(:nutrient_profile).permit(
      :name,
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
