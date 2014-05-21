module ApplicationHelper
  def list_nutrients_for(usda_food)
    view = UsdaFoodNutrientListView.new(usda_food)
    view.render.html_safe
  end
end
