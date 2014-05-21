class RemoveNutrientsFromIngredients < ActiveRecord::Migration
  def up
    change_table :ingredients do |t|
      t.integer :nutrient_collection_id
      t.remove :calories
      t.remove :carbohydrates
      t.remove :protein
      t.remove :total_fat
      t.remove :saturated_fat
      t.remove :monounsaturated_fat
      t.remove :polyunsaturated_fat
      t.remove :omega_3
      t.remove :omega_6
      t.remove :total_fiber
      t.remove :soluble_fiber
      t.remove :insoluble_fiber
      t.remove :cholesterol
      t.remove :calcium
      t.remove :chloride
      t.remove :chromium
      t.remove :copper
      t.remove :iodine
      t.remove :iron
      t.remove :magnesium
      t.remove :manganese
      t.remove :molybdenum
      t.remove :phosphorus
      t.remove :potassium
      t.remove :selenium
      t.remove :sodium
      t.remove :sulfur
      t.remove :zinc
      t.remove :vitamin_a
      t.remove :vitamin_b6
      t.remove :vitamin_b12
      t.remove :vitamin_c
      t.remove :vitamin_e
      t.remove :vitamin_k
      t.remove :thiamin
      t.remove :riboflavin
      t.remove :niacin
      t.remove :folate
      t.remove :pantothenic_acid
      t.remove :biotin
      t.remove :choline
    end
  end

  def down
    change_table :ingredients do |t|
      t.remove :nutrient_collection_id
      t.integer :calories
      t.integer :carbohydrates
      t.integer :protein
      t.integer :total_fat
      t.integer :saturated_fat
      t.integer :monounsaturated_fat
      t.integer :polyunsaturated_fat
      t.integer :omega_3
      t.integer :omega_6
      t.integer :total_fiber
      t.integer :soluble_fiber
      t.integer :insoluble_fiber
      t.integer :cholesterol
      t.integer :calcium
      t.integer :chloride
      t.integer :chromium
      t.integer :copper
      t.integer :iodine
      t.integer :iron
      t.integer :magnesium
      t.integer :manganese
      t.integer :molybdenum
      t.integer :phosphorus
      t.integer :potassium
      t.integer :selenium
      t.integer :sodium
      t.integer :sulfur
      t.integer :zinc
      t.integer :vitamin_a
      t.integer :vitamin_b6
      t.integer :vitamin_b12
      t.integer :vitamin_c
      t.integer :vitamin_e
      t.integer :vitamin_k
      t.integer :thiamin
      t.integer :riboflavin
      t.integer :niacin
      t.integer :folate
      t.integer :pantothenic_acid
      t.integer :biotin
      t.integer :choline
    end
  end
end
