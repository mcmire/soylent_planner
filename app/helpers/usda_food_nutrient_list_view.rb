require 'builder'

class UsdaFoodNutrientListView
  attr_reader :xml

  def initialize(usda_food)
    @usda_food = usda_food
    @output = ''
    @xml = Builder::XmlMarkup.new(target: @output)
  end

  def render
    nutrient_group_views.each(&:render)
    output
  end

  def find_foods_nutrient_by(nutrient_number)
    foods_nutrients_by_nutrient_number[nutrient_number.to_s]
  end

  private

  attr_reader :usda_food, :output

  def nutrient_group_views
    @_nutrient_group_views ||=
      ::Nutrient.by_group.map do |group_name, nutrient_numbers|
        NutrientGroupView.new(self, group_name, nutrient_numbers)
      end
  end

  def foods_nutrients_by_nutrient_number
    @_foods_nutrients_by_nutrient_number ||=
      @usda_food.foods_nutrients.
        includes(:nutrient).
        map { |foods_nutrient| FoodsNutrient.new(foods_nutrient) }.
        index_by(&:number)
  end

  #---

  class FoodsNutrient < SimpleDelegator
    def number
      nutrient.nutrient_number
    end

    def description
      if nutrient.nutrient_description == 'Energy'
        "#{nutrient.nutrient_description} (in #{units})"
      else
        nutrient.nutrient_description
      end
    end

    def value
      nutrient_value
    end

    def rounded_value
      value.round
    end

    def rendered_value
      if rounded_value == value
        rounded_value
      else
        value
      end
    end

    def units
      nutrient.units
    end
  end

  #---

  class NutrientGroupView
    def initialize(list_view, group_name, nutrient_numbers)
      @list_view = list_view
      @group_name = group_name
      @nutrient_numbers = nutrient_numbers
    end

    def render
      if foods_nutrient_views.any?
        xml.h3(group_name)
        xml.dl { foods_nutrient_views.each(&:render) }
      end
    end

    private

    attr_reader :list_view, :group_name, :nutrient_numbers

    delegate :xml, to: :list_view

    def foods_nutrient_views
      @_foods_nutrient_views ||=
        foods_nutrients.map do |foods_nutrient|
          FoodsNutrientView.new(self, foods_nutrient)
        end
    end

    def foods_nutrients
      @_foods_nutrients ||=
        nutrient_numbers.
          map { |nutrient_number| list_view.find_foods_nutrient_by(nutrient_number) }.
          compact.
          select { |foods_nutrient| foods_nutrient.value > 0 }.
          sort_by(&:description)
    end
  end

  #---

  class FoodsNutrientView
    def initialize(group_view, foods_nutrient)
      @group_view = group_view
      @foods_nutrient = foods_nutrient
    end

    def render
      xml.dt do
        xml.text! "#{foods_nutrient.description}"
      end

      xml.dd do
        xml.text! "#{foods_nutrient.rendered_value} #{foods_nutrient.units}"
      end
    end

    private

    attr_reader :group_view, :foods_nutrient

    delegate :xml, to: :group_view
  end
end
