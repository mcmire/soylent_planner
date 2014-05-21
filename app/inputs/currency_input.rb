class CurrencyInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    template.content_tag(:span, '$', class: 'input-group-addon') +
    @builder.text_field(attribute_name, merged_input_options)
  end
end
