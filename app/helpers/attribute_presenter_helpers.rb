module AttributePresenterHelpers
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TranslationHelper

  def present(attribute_name)
    value = public_send(attribute_name)
    present_with_label(attribute_name, value)
  end

  def present_with_label(attribute_name, value)
    label = human_attribute_name(attribute_name)
    label_tag = content_tag(:b, label)
    "#{label_tag}: #{value}".html_safe
  end

  def present_with_unit(attribute_name)
    "#{present(attribute_name)} #{unit}".html_safe
  end

  def present_as_currency(attribute_name)
    value = number_to_currency(public_send(attribute_name))
    present_with_label(attribute_name, value)
  end
end
