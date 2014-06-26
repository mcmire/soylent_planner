class DiySoylentRecipeImportsController < ApplicationController
  def new
    @recipe_url = params[:recipe_url]
  end

  def create
    @recipe_url = params[:recipe_url]

    importer = DiySoylentRecipeImporter.new(@recipe_url)
    importer.call

    invalid_ingredient_details = importer.invalid_ingredients.map do |ingredient|
      "#{ingredient.name}: #{ingredient.errors.full_messages}"
    end.join('; ')

    if importer.failed?
      flash[:danger] = <<EOT.strip.gsub("\n", '<br>')
Recipe could not be imported.
These ingredients failed to import: #{invalid_ingredient_details}
EOT
      render :new
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
