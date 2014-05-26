class UnitConverter
  UNITS = {
    g: [1, :g],
    mg: [1_000, :g],
    µg: [1_000, :mg],
    ug: :µg
  }

  def convert(value, from_unit:, to_unit:)
    from_unit = from_unit.to_sym
    to_unit = to_unit.to_sym

    if from_unit != to_unit && UNITS.key?(from_unit) && UNITS.key?(to_unit)
      from_unit_definition = UNITS[from_unit]
      to_unit_definition = UNITS[to_unit]

      if to_unit_definition[1] != to_unit
        raise "Trying to convert from #{from_unit} to #{to_unit}"
      end

      value * (to_unit_definition[0].to_f / from_unit_definition[0])
    else
      value
    end
  end
end
