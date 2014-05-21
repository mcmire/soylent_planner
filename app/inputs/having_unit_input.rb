class HavingUnitInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    @builder.text_field(attribute_name, merged_input_options) +
    template.content_tag(:span, options.fetch(:unit), class: 'input-group-addon')
  end
end
