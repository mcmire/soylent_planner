class UsdaFoodsController < ApplicationController
  def index
    if params[:q]
      @usda_foods = UsdaFood.
        search_by_long_description(params[:q]).
        page(params[:page])
    end
  end

  def show
    @usda_food = UsdaFood.find(params[:id])
  end
end
