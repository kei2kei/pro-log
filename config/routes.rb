Rails.application.routes.draw do
  if Rails.env.development?
    require "letter_opener_web"
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  devise_for :users, controllers: {
    registrations: "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "pages#home"
  get "about", to: "pages#about"
  get "terms", to: "pages#terms"
  get "privacy", to: "pages#privacy"
  get "contact", to: "pages#contact"
  post "contact", to: "pages#create_contact"
  resource :profile, only: [ :show, :edit, :update ]

  resources :products, only: [ :index, :show ] do
    resources :reviews, only: [ :new, :create ]
  end
  resources :reviews, only: [ :show, :edit, :update, :destroy ]
  resources :bookmarks, only: [ :create, :destroy ], controller: "product_bookmarks"
  resources :likes, only: [ :create, :destroy ], controller: "review_likes"

  namespace :admin do
    resources :products do
      member do
        get :duplicate
      end
    end
    resources :rakuten_products do
      collection do
        get :search
      end
    end
  end
end
