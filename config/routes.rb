Rails.application.routes.draw do
  resources :ingredients, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :nutrient_profiles, only: [:index, :new, :create, :edit, :update]
  resources :usda_foods, only: [:index, :show]
  resources :diy_soylent_recipe_imports, only: [:new, :create]
  resource :optimal_recipe, only: :show
  resource :optimal_recipe_from_diy_soylent,
    only: [:new, :show],
    controller: 'optimal_recipes_from_diy_soylent'
  resource :optimal_recipe_from_usda_database,
    only: [:new, :show],
    controller: 'optimal_recipes_from_usda_database'

  get '/ingredients/new_from_usda_food',
    to: 'ingredients#new_from_usda_food',
    as: :new_ingredient_from_usda_food
  get '/ingredients/from_usda_food',
    to: 'ingredients#from_usda_food',
    as: :ingredient_from_usda_food
end
