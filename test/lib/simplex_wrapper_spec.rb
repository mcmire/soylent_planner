require_relative '../test_helper'
require_relative '../../lib/simplex_wrapper'

class SimplexWrapperTest < Minitest::Test
  def test_2x2
    problem = SimplexWrapper.maximization_problem do |p|
      p.objective_coefficients = [1, 1]
      p.add_constraint(
        coefficients: [2, 1],
        operator: :<=,
        rhs_value: 4
      )
      p.add_constraint(
        coefficients: [1, 2],
        operator: :<=,
        rhs_value: 3
      )
    end

    solution = problem.solve
    assert_arr_close_to [Rational(5, 3), Rational(2, 3)], solution
  end

  def test_2x2_b
    problem = SimplexWrapper.maximization_problem do |p|
      p.objective_coefficients = [3, 4]
      p.add_constraint(
        coefficients: [1, 1],
        operator: :<=,
        rhs_value: 4
      )
      p.add_constraint(
        coefficients: [2, 1],
        operator: :<=,
        rhs_value: 5
      )
    end

    solution = problem.solve
    assert_arr_close_to [0, 4], solution
  end

  def test_2x2_c
    problem = SimplexWrapper.maximization_problem do |p|
      p.objective_coefficients = [2, -1]
      p.add_constraint(
        coefficients: [1, 2],
        operator: :<=,
        rhs_value: 6
      )
      p.add_constraint(
        coefficients: [3, 2],
        operator: :<=,
        rhs_value: 12
      )
    end

    solution = problem.solve
    assert_arr_close_to [4, 0], solution
  end

  def test_3x3_a
    problem = SimplexWrapper.maximization_problem do |p|
      p.objective_coefficients = [60, 90, 300]
      p.add_constraint(
        coefficients: [1, 1, 1],
        operator: :<=,
        rhs_value: 600
      )
      p.add_constraint(
        coefficients: [1, 3, 0],
        operator: :<=,
        rhs_value: 600
      )
      p.add_constraint(
        coefficients: [2, 0, 1],
        operator: :<=,
        rhs_value: 600
      )
    end
    solution = problem.solve
    assert_arr_close_to [0, 0, 600], solution
  end

  def test_3x3_b
    problem = SimplexWrapper.maximization_problem do |p|
      p.objective_coefficients = [70, 210, 140]
      p.add_constraint(
        coefficients: [1, 1, 1],
        operator: :<=,
        rhs_value: 100
      )
      p.add_constraint(
        coefficients: [5, 4, 4],
        operator: :<=,
        rhs_value: 480
      )
      p.add_constraint(
        coefficients: [40, 20, 30],
        operator: :<=,
        rhs_value: 3200
      )
    end
    solution = problem.solve
    assert_arr_close_to [0, 100, 0], solution
  end

  def test_3x3_c
    problem = SimplexWrapper.maximization_problem do |p|
      p.objective_coefficients = [2, -1, 2]
      p.add_constraint(
        coefficients: [2, 1, 0],
        operator: :<=,
        rhs_value: 10
      )
      p.add_constraint(
        coefficients: [1, 2, -2],
        operator: :<=,
        rhs_value: 20
      )
      p.add_constraint(
        coefficients: [0, 1, 2],
        operator: :<=,
        rhs_value: 5
      )
    end
    solution = problem.solve
    assert_arr_close_to [5, 0, Rational(5, 2)], solution
  end

  def test_3x3_d
    problem = SimplexWrapper.maximization_problem do |p|
      p.objective_coefficients = [11, 16, 15]
      p.add_constraint(
        coefficients: [1, 2, Rational(3, 2)],
        operator: :<=,
        rhs_value: 12_000
      )
      p.add_constraint(
        coefficients: [Rational(2, 3), Rational(2, 3), 1],
        operator: :<=,
        rhs_value: 4_600
      )
      p.add_constraint(
        coefficients: [Rational(1, 2), Rational(1, 3), Rational(1, 2)],
        operator: :<=,
        rhs_value: 2_400
      )
    end
    solution = problem.solve
    assert_arr_close_to [600, 5_100, 800], solution
  end

  def test_3x3_e
    problem = SimplexWrapper.maximization_problem do |p|
      p.objective_coefficients = [5, 4, 3]
      p.add_constraint(
        coefficients: [2, 3, 1],
        operator: :<=,
        rhs_value: 5
      )
      p.add_constraint(
        coefficients: [4, 1, 2],
        operator: :<=,
        rhs_value: 11
      )
      p.add_constraint(
        coefficients: [3, 4, 2],
        operator: :<=,
        rhs_value: 8
      )
    end
    solution = problem.solve
    assert_arr_close_to [2, 0, 1], solution
  end

  def test_3x3_f
    problem = SimplexWrapper.maximization_problem do |p|
      p.objective_coefficients = [3, 2, -4]
      p.add_constraint(
        coefficients: [1, 4, 0],
        operator: :<=,
        rhs_value: 5
      )
      p.add_constraint(
        coefficients: [2, 4, -2],
        operator: :<=,
        rhs_value: 6
      )
      p.add_constraint(
        coefficients: [1, 1, -2],
        operator: :<=,
        rhs_value: 2
      )
    end
    solution = problem.solve
    assert_arr_close_to [4, 0, 1], solution
  end

  def test_3x3_g
    problem = SimplexWrapper.maximization_problem do |p|
      p.objective_coefficients = [2, -1, 8]
      p.add_constraint(
        coefficients: [2, -4, 6],
        operator: :<=,
        rhs_value: 3
      )
      p.add_constraint(
        coefficients: [-1, 3, 4],
        operator: :<=,
        rhs_value: 2
      )
      p.add_constraint(
        coefficients: [0, 0, 2],
        operator: :<=,
        rhs_value: 1
      )
    end
    solution = problem.solve
    assert_arr_close_to [Rational(17, 2), Rational(7,2), 0], solution
  end

  def test_3x4
    problem = SimplexWrapper.maximization_problem do |p|
      p.objective_coefficients = [100_000, 40_000, 18_000]
      p.add_constraint(
        coefficients: [20, 6, 3],
        operator: :<=,
        rhs_value: 182
      )
      p.add_constraint(
        coefficients: [0, 1, 0],
        operator: :<=,
        rhs_value: 10
      )
      p.add_constraint(
        coefficients: [-1, -1, 1],
        operator: :<=,
        rhs_value: 0
      )
      p.add_constraint(
        coefficients: [-9, 1, 1],
        operator: :<=,
        rhs_value: 0
      )
    end

    solution = problem.solve
    assert_arr_close_to [4, 10, 14], solution
  end

  def test_4x4
    problem = SimplexWrapper.maximization_problem do |p|
      #p.debug!
      p.objective_coefficients = [1, 2, 1, 2]
      p.add_constraint(
        coefficients: [1, 0, 1, 0],
        operator: :<=,
        rhs_value: 1
      )
      p.add_constraint(
        coefficients: [0, 1, 0, 1],
        operator: :<=,
        rhs_value: 4
      )
      p.add_constraint(
        coefficients: [1, 1, 0, 0],
        operator: :<=,
        rhs_value: 2
      )
      p.add_constraint(
        coefficients: [0, 0, 1, 1],
        operator: :<=,
        rhs_value: 2
      )
    end
    solution = problem.solve
    assert_arr_close_to [0, 2, 0, 2], solution
  end

  # Source: http://www.math.toronto.edu/mpugh/Teaching/APM236_04/bland
  def test_cycle
    problem = SimplexWrapper.maximization_problem do |p|
      p.objective_coefficients = [10, -57, -9, -24]
      p.add_constraint(
        coefficients: [0.5, -5.5, -2.5, 9],
        operator: :<=,
        rhs_value: 0
      )
      p.add_constraint(
        coefficients: [0.5, -1.5, -0.5, 1],
        operator: :<=,
        rhs_value: 0
      )
      p.add_constraint(
        coefficients: [1, 0, 0, 0],
        operator: :<=,
        rhs_value: 1
      )
    end

    solution = problem.solve
    assert_arr_close_to [1, 0, 1, 0], solution
  end

  def test_cycle2
    problem = SimplexWrapper.maximization_problem do |p|
      p.objective_coefficients = [2, 3, -1, -12]
      p.add_constraint(
        coefficients: [-2, -9, 1, 9],
        operator: :<=,
        rhs_value: 0
      )
      p.add_constraint(
        coefficients: [Rational(1, 3), 1, Rational(-1, 3), -2],
        operator: :<=,
        rhs_value: 0
      )
    end
    assert_raises SimplexWrapper::UnsolvableProblem do
      problem.solve
    end
  end

  # Source: https://www.math.washington.edu/~burke/crs/407/notes/section1.pdf
  def test_cup_factory
    problem = SimplexWrapper.maximization_problem do |p|
      p.objective_coefficients = [25, 20]
      p.add_constraint(
        coefficients: [20, 12],
        operator: :<=,
        rhs_value: 1800
      )
      p.add_constraint(
        coefficients: [1, 1],
        operator: :<=,
        rhs_value: 8 * 15
      )
    end
    solution = problem.solve
    assert_arr_close_to [45, 75], solution
  end

  def test_unbounded
    problem = SimplexWrapper.maximization_problem do |p|
      p.objective_coefficients = [1, 1, 1]
      p.add_constraint(
        coefficients: [3, 1, -2],
        operator: :<=,
        rhs_value: 5
      )
      p.add_constraint(
        coefficients: [4, 3, 0],
        operator: :<=,
        rhs_value: 7
      )
    end
    assert_raises SimplexWrapper::UnsolvableProblem do
      problem.solve
    end
  end

  def test_unbounded_2
    problem = SimplexWrapper.minimization_problem do |p|
      p.objective_coefficients = [25, 100, 55]
      p.add_constraint(
        coefficients: [107, 100, 0],
        operator: :>=,
        rhs_value: 2440
      )
      p.add_constraint(
        coefficients: [107, 100, 0],
        operator: :<=,
        rhs_value: 3000
      )
      p.add_constraint(
        coefficients: [9, 0, 0],
        operator: :>=,
        rhs_value: 190
      )
      p.add_constraint(
        coefficients: [9, 0, 0],
        operator: :<=,
        rhs_value: 300
      )
      p.add_constraint(
        coefficients: [4, 0, 0],
        operator: :>=,
        rhs_value: 127
      )
      p.add_constraint(
        coefficients: [4, 0, 0],
        operator: :<=,
        rhs_value: 225
      )
    end

    assert_raises SimplexWrapper::UnsolvableProblem do
      problem.solve
    end
  end

  # Source: http://college.cengage.com/mathematics/larson/elementary_linear/4e/shared/downloads/c09s4.pdf
  def test_minimization_problem
    problem = SimplexWrapper.minimization_problem do |p|
      p.objective_coefficients = [Rational(3, 25), Rational(3, 20)]
      p.add_constraint(
        coefficients: [60, 60],
        operator: :>=,
        rhs_value: 300
      )
      p.add_constraint(
        coefficients: [12, 6],
        operator: :>=,
        rhs_value: 36
      )
      p.add_constraint(
        coefficients: [10, 30],
        operator: :>=,
        rhs_value: 90
      )
    end

    solution = problem.solve
    assert_arr_close_to [3, 2], solution
  end

  # Source: http://college.cengage.com/mathematics/larson/elementary_linear/4e/shared/downloads/c09s5.pdf
  def test_maximization_problem_with_mixed_constraints
    problem = SimplexWrapper.maximization_problem do |p|
      p.objective_coefficients = [1, 1, 2]
      p.add_constraint(
        coefficients: [2, 1, 1],
        operator: :<=,
        rhs_value: 50
      )
      p.add_constraint(
        coefficients: [2, 1, 0],
        operator: :>=,
        rhs_value: 36
      )
      p.add_constraint(
        coefficients: [1, 0, 1],
        operator: :>=,
        rhs_value: 10
      )
    end

    solution = problem.solve
    assert_arr_close_to [0, 36, 14], solution
  end

  # Source: http://college.cengage.com/mathematics/larson/elementary_linear/4e/shared/downloads/c09s5.pdf
  def test_minimization_problem_with_mixed_constraints
    problem = SimplexWrapper.minimization_problem do |p|
      p.objective_coefficients = [4, 2, 1]
      p.add_constraint(
        coefficients: [2, 3, 4],
        operator: :<=,
        rhs_value: 14
      )
      p.add_constraint(
        coefficients: [3, 1, 5],
        operator: :>=,
        rhs_value: 4
      )
      p.add_constraint(
        coefficients: [1, 4, 3],
        operator: :>=,
        rhs_value: 6
      )
    end

    solution = problem.solve
    assert_arr_close_to [0, 0, 2], solution
  end

  def test_finding_pivot_column_via_trial_and_error
    problem = SimplexWrapper.minimization_problem do |p|
      p.objective_coefficients = ['1/25', '1/100']
      p.add_constraint(
        coefficients: ['243/50', '221/25'],
        operator: :>=,
        rhs_value: 2500
      )
      p.add_constraint(
        coefficients: ['243/50', '221/25'],
        operator: :<=,
        rhs_value: 3000
      )
      p.add_constraint(
        coefficients: ['21/50', '0'],
        operator: :>=,
        rhs_value: 250
      )
      p.add_constraint(
        coefficients: ['21/50', '0'],
        operator: :<=,
        rhs_value: 300
      )
    end

    solution = problem.solve
    assert_arr_close_to ['12500/21'.to_r, 0], solution
  end

  private

  def assert_arr_close_to(arr1, arr2)
    arr1.zip(arr2).each do |value1, value2|
      # not completely concerned about accuracy...
      assert_in_epsilon value2, value1, 1.0e-11
    end
  end
end
