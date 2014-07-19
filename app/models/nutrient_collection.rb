class NutrientCollection < ActiveRecord::Base
  MODIFIABLE_ATTRIBUTE_NAMES = [
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
    :vitamin_d,
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

  NAMES_OF_VITAMINS = %i[
    vitamin_a
    vitamin_b6
    vitamin_b12
    vitamin_c
    vitamin_d
    vitamin_e
    vitamin_k
    thiamin
    riboflavin
    niacin
    folate
    pantothenic_acid
    biotin
  ]

  NAMES_OF_MINERALS = %i[
    calcium
    chloride
    chromium
    copper
    iodine
    iron
    magnesium
    manganese
    molybdenum
    phosphorus
    potassium
    selenium
    sodium
    sulfur
    zinc
  ]

  def self.modifiable_attribute_names
    MODIFIABLE_ATTRIBUTE_NAMES
  end

  def self.unit_for(attribute_name)
    UNITS_BY_ATTRIBUTE_NAME.fetch(attribute_name.to_sym, 'g')
  end

  def self.names_of_vitamins
    NAMES_OF_VITAMINS
  end

  def self.names_of_minerals
    NAMES_OF_MINERALS
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
