Rails.application.routes.draw do
  get 'sessions/new'
  root 'sessions#new'
  get 'boards/setting'
  get 'boards/index'

  resources :users
  resources :comments
  
  get '/login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
end
