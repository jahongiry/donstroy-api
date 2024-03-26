Rails.application.routes.draw do
  get 'certificates/show'
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
      post '/login', to: 'sessions#create'
      resources :courses 
      resources :students
    end
  end
end
