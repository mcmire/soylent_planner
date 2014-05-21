class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.string :name, null: false, default: ''
      t.string :form, null: false, default: 'powder'
      t.string :unit, default: 'g'
      t.integer :container_size, null: false
      t.decimal :cost, precision: 2
      t.string :source
      t.string :link
      t.integer :daily_serving
      t.integer :serving_size
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
