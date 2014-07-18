module AttributePresenterHelpers
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TranslationHelper

  def present_with_label(attribute_name, value)
    if value
      label = human_attribute_name(attribute_name)
      dt_tag = content_tag(:dt, label)
      dd_tag = content_tag(:dd, value)
      dt_tag + dd_tag
    end
  end

  def present_with_unit(attribute_name)
    value = public_send(attribute_name)

    if value && value > 0
      value_parts = [ value, unit ]
      value_and_unit = value_parts.join(" ")
      present_with_label(attribute_name, value_and_unit)
    end
  end

  def present_as_currency(attribute_name)
    value = number_to_currency(public_send(attribute_name))
    present_with_label(attribute_name, value)
  end
end
