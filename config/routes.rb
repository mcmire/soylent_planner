Rails.application.routes.draw do
  resources :ingredients, only: [:index, :new, :create, :edit, :update]
end
