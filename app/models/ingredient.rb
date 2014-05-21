class Ingredient < ActiveRecord::Base
  FORMS = %w(powder liquid paste pill)
  UNITS = %w(g ml portion pill)

  def self.forms; FORMS; end
  def self.units; UNITS; end

  validates :name, :form, :unit, :container_size, presence: true

  belongs_to :nutrient_collection, dependent: :destroy

  accepts_nested_attributes_for :nutrient_collection

  def form=(form)
    unless FORMS.include?(form)
      raise ArgumentError, "Invalid form '#{form}'. Valid forms are: #{FORMS}"
    end

    super
  end

  def unit=(unit)
    unless UNITS.include?(unit)
      raise ArgumentError, "Invalid unit '#{unit}'. Valid units are: #{UNITS}"
    end

    super
  end
end
