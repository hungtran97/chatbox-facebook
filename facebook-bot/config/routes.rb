Rails.application.routes.draw do
  resources :messengers, only: [:index, :create]
end
