class OptimalRecipeGeneratorFromUsdaDatabase
  class NutrientCollection
    COLUMN_NAMES = ::NutrientCollection.column_names

    COLUMN_NAMES.each do |column_name|
      attr_accessor column_name
    end

    def self.from_row(row)
      new.tap do |nutrient_collection|
        COLUMN_NAMES.each do |column_name|
          nutrient_collection.__send__("#{column_name}=", row[column_name])
        end
      end
    end
  end
end
