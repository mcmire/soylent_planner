class AddDigestToIngredientsAndNutrientCollections < ActiveRecord::Migration
  def up
    change_table :ingredients do |t|
      t.string :digest, null: false
    end

    change_table :nutrient_collections do |t|
      t.string :digest, null: false
    end
  end

  def down
    change_table :ingredients do |t|
      t.remove :digest
    end

    change_table :nutrient_collections do |t|
      t.remove :digest
    end
  end
end
