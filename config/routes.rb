Rails.application.routes.draw do
  resources :tasks do
    member do
      patch 'finish'
      patch 'start'
      patch 'suspend'
    end
  end
  root to: 'tasks#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/logout' => 'sessions#destroy', as: :logout
end
