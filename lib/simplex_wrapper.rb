require 'simplex'

module SimplexWrapper
  def self.maximization_problem(&block)
    Simplex.maximization_problem(&block)
  end

  def self.minimization_problem(&block)
    Simplex.minimization_problem(&block)
  end

  UnboundedProblem = ::Simplex::UnboundedProblem
end
