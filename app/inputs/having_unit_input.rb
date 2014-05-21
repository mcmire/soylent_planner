class HavingUnitInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    if options[:parent_object]
      unit = options[:parent_object].formatted_unit_for(attribute_name)
    else
      unit = object.unit
    end

    @builder.text_field(attribute_name, merged_input_options) +
    template.content_tag(:span, unit, class: 'input-group-addon')
  end
end
