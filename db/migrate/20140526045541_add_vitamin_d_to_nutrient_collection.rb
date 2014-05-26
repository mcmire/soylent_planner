class AddVitaminDToNutrientCollection < ActiveRecord::Migration
  def up
    change_table :nutrient_collections do |t|
      t.decimal :vitamin_d
    end
  end

  def down
    change_table :nutrient_collections do |t|
      t.remove :vitamin_d
    end
  end
end
