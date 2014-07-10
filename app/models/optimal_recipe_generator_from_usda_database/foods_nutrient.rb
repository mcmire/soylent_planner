class OptimalRecipeGeneratorFromUsdaDatabase
  class FoodsNutrient
    COLUMN_NAMES = %w(
      nutrient_databank_number
      nutrient_number
      nutrient_value
      nutrient
    )

    COLUMN_NAMES.each do |column_name|
      attr_accessor column_name
    end

    def self.from_row(row)
      new.tap do |foods_nutrient|
        COLUMN_NAMES.each do |column_name|
          foods_nutrient.__send__("#{column_name}=", row[column_name])
        end
      end
    end

    def nutrient=(nutrient)
      @nutrient = Nutrient.from_row(nutrient)
    end
  end
end
