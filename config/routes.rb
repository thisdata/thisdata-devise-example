Rails.application.routes.draw do
  root to: 'visitors#index'

  devise_for :users, controllers: { :sessions => "my_sessions" }
  resources :users
end
