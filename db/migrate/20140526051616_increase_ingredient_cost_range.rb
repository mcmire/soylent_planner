class IncreaseIngredientCostRange < ActiveRecord::Migration
  def up
    change_table :ingredients do |t|
      t.change :cost, :decimal, precision: 1000, scale: 2
    end
  end

  def down
    change_table :ingredients do |t|
      t.change :cost, :decimal, precision: 2, scale: 0
    end
  end
end
