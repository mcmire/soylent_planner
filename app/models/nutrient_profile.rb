class NutrientProfile < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :nutrient_collection

  accepts_nested_attributes_for :nutrient_collection

  def formatted_unit_for(attribute_name)
    NutrientCollection.unit_for(attribute_name)
  end
end
