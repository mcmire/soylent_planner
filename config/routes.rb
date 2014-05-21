Rails.application.routes.draw do
  resources :ingredients, only: [:index, :new, :create, :edit, :update]
  resources :nutrient_profiles, only: [:index, :new, :create, :edit, :update]
  resources :usda_foods, only: [:index, :show]
end
