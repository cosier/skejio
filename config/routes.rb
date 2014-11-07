Rails.application.routes.draw do


  devise_for :users, controllers: {
    registrations: 'registrations'
  }

  scope :manage do
    resources :manage_businesses, path: 'businesses'
    get '/businesses', to: 'manage_businesses#index', as: :businesses
    get '/', to: 'manage#dashboard', as: :manage_dashboard
  end

  get '/businesses/:id/pending', to: 'businesses#pending', as: :business_pending
  get '/businesses/:id/dashboard', to: 'businesses#dashboard', as: :business_dashboard

  resources :businesses do
    get  '/subaccounts', to: 'businesses#subaccounts', as: :subaccounts
    get  '/search_number', to: 'businesses#search_number', as: :search_number
    post '/subaccount_number_search', to: 'businesses#search_numbers', as: :search_numbers
    get  '/buy_phone_number_path', to: 'businesses#buy_phone_number', as: :buy_phone_number
    post '/send_sms', to: 'businesses#send_sms', as: :send_sms
    post '/make_a_call', to: 'businesses#make_a_call', as: :make_a_call
    get  '/new_subaccount', to: 'businesses#new_subaccount', as: :new_subaccount
    post '/create_subaccount', to: 'businesses#create_subaccount', as: :create_subaccount

    resources :offices
    resources :numbers
  end


  devise_scope :user do
    # tmp devise fix until we hook our links with javascript for :delete requests
    match 'users/sign_out' => "devise/sessions#destroy", via: [:get]
  end

  root 'welcome#index'

end
