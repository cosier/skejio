Rails.application.routes.draw do



  devise_for :users, controllers: {
    registrations: 'registrations'
  }

  scope :manage do
    resources :manage_businesses, path: 'businesses'
    get '/businesses', to: 'manage_businesses#index', as: :businesses
    get '/', to: 'manage#dashboard', as: :manage_dashboard
  end

  resources :businesses do
    resources :offices, path: 'offices', as: :offices
  end

  get '/business/:slug/pending', to: 'businesses#pending', as: :business_pending
  get '/business/:slug', to: 'businesses#dashboard', as: :business_dashboard

  devise_scope :user do
    # tmp devise fix until we hook our links with javascript for :delete requests
    match 'users/sign_out' => "devise/sessions#destroy", via: [:get]
  end

  root 'welcome#index'

end
