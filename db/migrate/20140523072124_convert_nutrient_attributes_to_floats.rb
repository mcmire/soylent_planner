class ConvertNutrientAttributesToFloats < ActiveRecord::Migration
  def up
    change_table :nutrient_collections do |t|
      t.change :calories, :decimal
      t.change :carbohydrates, :decimal
      t.change :protein, :decimal
      t.change :total_fat, :decimal
      t.change :saturated_fat, :decimal
      t.change :monounsaturated_fat, :decimal
      t.change :polyunsaturated_fat, :decimal
      t.change :omega_3, :decimal
      t.change :omega_6, :decimal
      t.change :total_fiber, :decimal
      t.change :soluble_fiber, :decimal
      t.change :insoluble_fiber, :decimal
      t.change :cholesterol, :decimal
      t.change :calcium, :decimal
      t.change :chloride, :decimal
      t.change :chromium, :decimal
      t.change :copper, :decimal
      t.change :iodine, :decimal
      t.change :iron, :decimal
      t.change :magnesium, :decimal
      t.change :manganese, :decimal
      t.change :molybdenum, :decimal
      t.change :phosphorus, :decimal
      t.change :potassium, :decimal
      t.change :selenium, :decimal
      t.change :sodium, :decimal
      t.change :sulfur, :decimal
      t.change :zinc, :decimal
      t.change :vitamin_a, :decimal
      t.change :vitamin_b6, :decimal
      t.change :vitamin_b12, :decimal
      t.change :vitamin_c, :decimal
      t.change :vitamin_e, :decimal
      t.change :vitamin_k, :decimal
      t.change :thiamin, :decimal
      t.change :riboflavin, :decimal
      t.change :niacin, :decimal
      t.change :folate, :decimal
      t.change :pantothenic_acid, :decimal
      t.change :biotin, :decimal
      t.change :choline, :decimal
    end
  end

  def down
    change_table :nutrient_collections do |t|
      t.change :calories, :integer
      t.change :carbohydrates, :integer
      t.change :protein, :integer
      t.change :total_fat, :integer
      t.change :saturated_fat, :integer
      t.change :monounsaturated_fat, :integer
      t.change :polyunsaturated_fat, :integer
      t.change :omega_3, :integer
      t.change :omega_6, :integer
      t.change :total_fiber, :integer
      t.change :soluble_fiber, :integer
      t.change :insoluble_fiber, :integer
      t.change :cholesterol, :integer
      t.change :calcium, :integer
      t.change :chloride, :integer
      t.change :chromium, :integer
      t.change :copper, :integer
      t.change :iodine, :integer
      t.change :iron, :integer
      t.change :magnesium, :integer
      t.change :manganese, :integer
      t.change :molybdenum, :integer
      t.change :phosphorus, :integer
      t.change :potassium, :integer
      t.change :selenium, :integer
      t.change :sodium, :integer
      t.change :sulfur, :integer
      t.change :zinc, :integer
      t.change :vitamin_a, :integer
      t.change :vitamin_b6, :integer
      t.change :vitamin_b12, :integer
      t.change :vitamin_c, :integer
      t.change :vitamin_e, :integer
      t.change :vitamin_k, :integer
      t.change :thiamin, :integer
      t.change :riboflavin, :integer
      t.change :niacin, :integer
      t.change :folate, :integer
      t.change :pantothenic_acid, :integer
      t.change :biotin, :integer
      t.change :choline, :integer
    end
  end
end

