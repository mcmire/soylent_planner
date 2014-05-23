Rails.application.routes.draw do
  resources :ingredients, only: [:index, :new, :create, :edit, :update]
  resources :nutrient_profiles, only: [:index, :new, :create, :edit, :update]
  resources :usda_foods, only: [:index, :show]

  get '/ingredients/new_from_usda_food',
    to: 'ingredients#new_from_usda_food',
    as: :new_ingredient_from_usda_food
end
