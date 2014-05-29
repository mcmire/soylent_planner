class MakeServingSizeAFloat < ActiveRecord::Migration
  def up
    change_table :ingredients do |t|
      t.change :serving_size, :decimal
    end
  end

  def down
    change_table :ingredients do |t|
      t.change :serving_size, :integer
    end
  end
end
