class HavingUnitInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    build_input_group(attribute_name, wrapper_options)
  end

  private

  def build_input_group(attribute_name, wrapper_options)
    @builder.text_field(attribute_name, merged_input_options(wrapper_options)) +
    template.content_tag(:span, unit, class: 'input-group-addon')
  end

  def merged_input_options(wrapper_options)
    merge_wrapper_options(input_html_options, wrapper_options)
  end

  def unit
    if options[:parent_object]
      unit = options[:parent_object].formatted_unit_for(attribute_name)
    else
      unit = object.unit
    end
  end
end
