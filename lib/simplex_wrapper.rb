require 'lpsolve'

module SimplexWrapper
  def self.maximization_problem(&block)
    Problem.new(:maximization, &block)
  end

  def self.minimization_problem(&block)
    Problem.new(:minimization, &block)
  end

  class Problem
    CONSTANTS_BY_OPERATOR = {
      :>= => LPSolve::GE,
      :<= => LPSolve::LE
    }

    def initialize(type)
      @type = type

      @num_columns = 0
      @num_constraints = 0

      if block_given?
        yield self
        solver.set_add_rowmode(false)
      end
    end

    def objective_coefficients=(coefficients)
      unless defined?(@solver)
        @solver = build_solver(coefficients.size)
      end

      solver.set_obj_fnex(column_values_with_indices(coefficients))
    end

    def add_constraint(constraint)
      unless defined?(@solver)
        @solver = build_solver(constraint[:coefficients].size)
      end

      @num_constraints += 1

      solver.add_constraintex(
        "C#{num_constraints}",
        column_values_with_indices(constraint[:coefficients]),
        CONSTANTS_BY_OPERATOR[constraint[:operator]],
        constraint[:rhs_value]
      )
    end

    def solve
      result = solver.solve

      case result
      when LPSolve::OPTIMAL
        num_columns.times.map do |variable_index|
          solver.variables[variable_index]
        end
      when -1
        raise ArgumentError, <<EOT

  Matrix is empty. Either this means none of the data you added to the matrix
  was valid, or you haven't added any data yet.
EOT
      else
        raise UnsolvableProblem
      end
    end

    def debug!
      @debug = true
    end

    def debug?
      !!@debug
    end

    protected

    attr_reader :type, :num_columns, :solver, :num_constraints, :num_unknowns

    private

    def build_solver(num_columns)
      @num_columns = num_columns

      LPSolve.new(0, num_columns).tap do |solver|
        solver.verbose = LPSolve::IMPORTANT

        solver.set_add_rowmode(true)

        if type == :maximization
          solver.set_maxim
        else
          solver.set_minim
        end

        if debug?
          solver.verbose = LPSolve::FULL
          solver.debug = true
          solver.trace = true
        end
      end
    end

    def column_values_with_indices(values)
      values.map.with_index do |value, index|
        [index+1, value.to_s.to_r.to_f]
      end
    end
  end

  class UnsolvableProblem < StandardError; end
end
