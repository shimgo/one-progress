Rails.application.routes.draw do
  resources :tasks
  root to: 'tasks#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/logout' => 'sessions#destroy', as: :logout
end
