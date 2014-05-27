class MinAndMaxInput < HavingUnitInput
  def input(wrapper_options)
    build_input_group(attribute_name + '_min') + build_input_group(attribute_name + '_max')
  end
end
