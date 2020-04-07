Rails.application.routes.draw do
  resources :sessions
  root to: "home#index"
  get "users/me" => "users#me"
  resources :users do 
  	member do
  		get 'widgets'
  	end
  end
  resource :session, only: [:new, :create, :destroy]
  resources :widgets
end
