Rails.application.routes.draw do
  resources :tasks do
    member do
      patch 'finish'
      patch 'start'
      patch 'resume'
      patch 'suspend'
    end
  end

  resource :user do
    get :retire
  end

  root to: 'tasks#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/auth/failure' => 'sessions#failure'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy', as: :logout
end
