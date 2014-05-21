class CreateNutrientProfiles < ActiveRecord::Migration
  def change
    create_table :nutrient_profiles do |t|
      t.integer :nutrient_collection_id
      t.string :name, null: false
    end
  end
end
