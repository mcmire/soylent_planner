class UsdaFood < UsdaNutrientDatabase::Food
  include PgSearch

  pg_search_scope :search_by_long_description,
    against: :long_description,
    ranked_by: ':trigram'
end
