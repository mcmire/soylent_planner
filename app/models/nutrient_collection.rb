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
    vitamin_d: 'IU',
    vitamin_e: 'IU',
    vitamin_k: 'µg',
    zinc: 'mg',
  }
  ATTRIBUTES_TO_EXCLUDE_FROM_DIGEST = [
    'id',
    'created_at',
    'updated_at',
    'digest'
  ]

  def self.unit_for(attribute_name)
    UNITS_BY_ATTRIBUTE_NAME.fetch(attribute_name, 'g')
  end

  before_save :write_digest

  def calculated_digest
    Digest::MD5.hexdigest(json_encoded_attributes)
  end

  private

  def write_digest
    self.digest = calculated_digest
  end

  def json_encoded_attributes
    attributes = self.attributes.
      except(*ATTRIBUTES_TO_EXCLUDE_FROM_DIGEST).
      to_a.
      sort { |a, b| a[0] <=> b[0] }

    JSON.generate(attributes)
  end
end
