class OptimalRecipeGeneratorFromUsdaDatabase
  class Nutrient
    COLUMN_NAMES = %w(nutrient_number nutrient_description units)

    COLUMN_NAMES.each do |column_name|
      attr_accessor column_name
    end

    def self.from_row(row)
      new.tap do |nutrient|
        COLUMN_NAMES.each do |column_name|
          nutrient.__send__("#{column_name}=", row[column_name])
        end
      end
    end
  end
end
