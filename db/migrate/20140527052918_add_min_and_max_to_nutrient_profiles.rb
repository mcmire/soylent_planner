class AddMinAndMaxToNutrientProfiles < ActiveRecord::Migration
  def up
    change_table :nutrient_profiles do |t|
      t.remove :nutrient_collection_id
      t.integer :min_nutrient_collection_id, null: false
      t.integer :max_nutrient_collection_id, null: false
    end
  end

  def down
    change_table :nutrient_profiles do |t|
      t.remove :min_nutrient_collection_id
      t.remove :max_nutrient_collection_id
      t.integer :nutrient_collection_id, null: false
    end
  end
end
