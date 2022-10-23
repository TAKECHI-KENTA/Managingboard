Rails.application.routes.draw do
  root 'boards#index'
  get 'boards/setting'
  get 'boards/index'

  resources :users
  resources :comments
end
