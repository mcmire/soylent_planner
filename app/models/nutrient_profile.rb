class NutrientProfile < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :nutrient_collection, dependent: :destroy
  belongs_to :min_nutrient_collection, class: NutrientCollection
  belongs_to :max_nutrient_collection, class: NutrientCollection

  accepts_nested_attributes_for :min_nutrient_collection
  accepts_nested_attributes_for :max_nutrient_collection

  def formatted_unit_for(attribute_name)
    NutrientCollection.unit_for(attribute_name)
  end
end
