module ApplicationHelper
  NUTRIENT_COLLECTION_LABELS = {
    monounsaturated_fat: 'Monounsat. fat',
    polyunsaturated_fat: 'Polyunsat. fat',
    omega_3: 'Omega-3',
    omega_6: 'Omega-6',
    vitamin_a: 'Vitamin A',
    vitamin_b6: 'Vitamin B6',
    vitamin_b12: 'Vitamin B12',
    vitamin_c: 'Vitamin C',
    vitamin_d: 'Vitamin D',
    vitamin_e: 'Vitamin E',
    vitamin_k: 'Vitamin K',
    pantothenic_acid: 'Panto. acid',
  }

  def list_nutrients_for(usda_food)
    view = UsdaFoodNutrientListView.new(usda_food)
    view.render.html_safe
  end

  def nutrient_collection_attributes
    NutrientCollection.modifiable_attribute_names.map do |attribute_name|
      {
        name: attribute_name,
        label: nutrient_label_for(attribute_name)
      }
    end
  end

  def nutrient_label_for(attribute_name)
    NUTRIENT_COLLECTION_LABELS.fetch(attribute_name) do
      attribute_name.to_s.humanize
    end
  end
end
