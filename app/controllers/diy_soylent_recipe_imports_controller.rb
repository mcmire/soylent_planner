class DiySoylentRecipeImportsController < ApplicationController
  def new
    @url = params[:url]
  end

  def create
    importer = DiySoylentRecipeImporter.new(params[:url])
    importer.call

    invalid_ingredient_details = importer.invalid_ingredients.map do |ingredient|
      "#{ingredient.name}: #{ingredient.errors.full_messages}"
    end.join('; ')

    if importer.failed?
      flash[:danger] = <<EOT.strip.gsub("\n", '<br>')
Recipe could not be imported.
These ingredients failed to import: #{invalid_ingredient_details}
EOT
      redirect_to :back
    else
      valid_ingredient_names = importer.valid_ingredients.map(&:name)
      existing_ingredient_names = importer.existing_ingredients.map(&:name)
      flash[:success] = <<EOT.strip.gsub("\n", '<br>')
Import finished.
These ingredients were imported: #{valid_ingredient_names}.
These ingredients were not imported: #{invalid_ingredient_details}.
These ingredients already exist and were not imported: #{existing_ingredient_names}
EOT
      redirect_to ingredients_path
    end
  end
end
