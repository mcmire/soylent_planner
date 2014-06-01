require 'matrix'

module Simplex
  Infeasible = Class.new(ArgumentError)

  MaximumTableaus = 500

  module GeneralLinearProgrammingProblem # Phase 1
    def solved?
      @starred_rows ||= each_with_index.each_with_object([]) do |(value, row, column), starred_rows|
        starred_rows << row if column >= free_variable_size and value < 0
      end

      @starred_rows.none?
    end

    def pivot_row
      pivot_row = lowest_test_ratio_rows.find do |row|
        @starred_rows.include?(row)
      end

      pivot_row ||= lowest_test_ratio_rows.first
    end

    def pivot_column
      values = @rows[@starred_rows.first][0..-2]
      maximum = values.max
      values.index(maximum)
    end
  end

  module StandardMaximizationProblem # Phase 2
    def solved?
      objective.none? do |value|
        value < 0
      end
    end

    def pivot_row
      lowest_test_ratio_rows.first
    end

    def pivot_column
      minimum = objective.min
      objective.index(minimum)
    end
  end

  def maximize(&block)
    @block = block
    solve
  end

  def minimize(&block)
    @block = block
    solve[0...-1] << solve.last * -1
  end

  private
  def solve
    @active_variables = row_size.times.map do |time|
      free_variable_size + time
    end

    @rows = @rows.delete_if do |row|
      row.all? do |value|
        value == 0
      end
    end

    extend GeneralLinearProgrammingProblem
    pivot until solved?

    extend StandardMaximizationProblem
    pivot until solved?

    answers = (column_size - 1).times.map do |time|
      if row = @active_variables.index(time) and @rows[row][time] > 0
        # Active variables that are zero?
        Rational(@rows[row].last, @rows[row][time])
      else
        0
      end
    end
  end

  def pivot
    @count ||= 0
    @count += 1
    raise Infeasible if @count > MaximumTableaus

    @pivot_column = pivot_column
    @pivot_row = pivot_row

    pivot_value = @rows[@pivot_row][@pivot_column]

    product = nil

    each_with_index do |value, row, column|
      next if row == @pivot_row

      if column == 0
        if pivot_value == 0
          product = 0
        else
          product = Rational(@rows[row][@pivot_column], pivot_value)
        end
      end

      @rows[row][column] = (value - product * @rows[@pivot_row][column])
    end

    @rows[@pivot_row].map do |value|
      if pivot_value == 0
        0
      else
        Rational(value, pivot_value)
      end
    end

    @active_variables[@pivot_row] = @pivot_column
    @starred_rows.delete(@pivot_row)

    @block.call(@rows) if @block
  end

  def lowest_test_ratio_rows
    test_ratios = constraints.map do |constraint|
      denominator = constraint[@pivot_column]
      denominator > 0 ? Rational(constraint.last, denominator) : Float::INFINITY
    end

    test_ratios.each_with_index.each_with_object([]) do |(test_ratio, index), lowest_test_ratio_rows|
      lowest_test_ratio_rows << index if test_ratio == test_ratios.min
    end
  end

  def constraints
    @rows[0..-2]
  end

  def objective
    @rows.last[0..-2]
  end

  def free_variable_size
    column_size - constraints.size - 2
  end
end
