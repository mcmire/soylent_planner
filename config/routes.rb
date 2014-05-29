Rails.application.routes.draw do
  resources :ingredients, only: [:index, :new, :create, :edit, :update]
  resources :nutrient_profiles, only: [:index, :new, :create, :edit, :update] do
    resources :formulae, only: :index
  end
  resources :usda_foods, only: [:index, :show]
  resources :diy_soylent_recipe_imports, only: [:new, :create]

  get '/ingredients/new_from_usda_food',
    to: 'ingredients#new_from_usda_food',
    as: :new_ingredient_from_usda_food
end
