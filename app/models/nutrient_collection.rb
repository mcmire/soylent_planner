class NutrientCollection < ActiveRecord::Base
  UNITS_BY_ATTRIBUTE_NAME = {
    biotin: 'µg',
    calories: 'kcal',
    choline: 'mg',
    chromium: 'µg',
    copper: 'mg',
    folate: 'µg',
    iodine: 'µg',
    iron: 'mg',
    magnesium: 'mg',
    manganese: 'mg',
    molybdenum: 'µg',
    niacin: 'mg',
    pantothenic_acid: 'mg',
    riboflavin: 'mg',
    selenium: 'µg',
    thiamin: 'mg',
    vitamin_a: 'IU',
    vitamin_b12: 'µg',
    vitamin_b6: 'mg',
    vitamin_c: 'mg',
    vitamin_e: 'IU',
    vitamin_k: 'µg',
    zinc: 'mg',
  }

  def self.unit_for(attribute_name)
    UNITS_BY_ATTRIBUTE_NAME.fetch(attribute_name, 'g')
  end
end
