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
    nutrient_names.map do |attribute_name|
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

  def nutrient_names
    NutrientCollection.modifiable_attribute_names
  end

  def unit_for(nutrient_name)
    NutrientCollection.unit_for(nutrient_name)
  end

  def percentage(number)
    if number
      "#{round(number * 100)}%"
    end
  end

  def percentage_or_na(number)
    if number
      percentage(number)
    else
      '<i>n/a</i>'.html_safe
    end
  end

  def round(number)
    number_with_precision(number.to_f,
      precision: OptimalRecipeGenerator.precision,
      delimiter: ','
    )
  end

  def currency(number)
    number_to_currency(number.to_f,
      precision: OptimalRecipeGenerator.precision
    )
  end

  def float(number)
    if number
      number.to_f
    end
  end

  def float_or_na(number)
    if number
      float(number)
    else
      '<i>n/a</i>'.html_safe
    end
  end

  def integer(number)
    number_with_delimiter(number.to_i, delimiter: ',')
  end

  def nutrient_completeness_score_class(recipe, nutrient)
    min_score = recipe.min_completeness_score_for_nutrient(nutrient)
    max_score = recipe.max_completeness_score_for_nutrient(nutrient)

    pp nutrient: nutrient.name,
       min_score: min_score.to_f,
       max_score: max_score.to_f

    if min_score > 0 && min_score < 1
      'min-requirement-underachieved'
    elsif max_score > 1
      'max-requirement-overachieved'
    end
  end
end
