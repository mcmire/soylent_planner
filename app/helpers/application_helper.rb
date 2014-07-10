module ApplicationHelper
  VISUAL_PRECISION = 2

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
    if number && !number.to_f.infinite?
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
      precision: VISUAL_PRECISION,
      delimiter: ','
    )
  end

  def round_rational(number)
    if number <= 0.01
      number.to_f.round(4)
    else
      number.round(2)
    end
  end

  def currency(number)
    number_to_currency(number.to_f, precision: 2)
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
    min_score = recipe.min_completeness_score_for_nutrient(nutrient).to_f
    max_score = recipe.max_completeness_score_for_nutrient(nutrient).to_f

    if nutrient.max_value > 0
      if (0.90..1).cover?(max_score)
        'max-requirement-achieved'
      elsif max_score > 1
        'max-requirement-overachieved'
      elsif min_score.infinite? && (0...0.2).cover?(max_score)
        'max-requirement-underachieved'
      elsif !min_score.infinite? && (0...1).cover?(min_score)
        'min-requirement-underachieved'
      end
    end
  end
end
