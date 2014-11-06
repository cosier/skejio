Rails.application.routes.draw do


  devise_for :users, controllers: {
    registrations: 'registrations'
  }

  scope :manage do
    resources :manage_businesses, path: 'businesses'
    get '/', to: 'manage#dashboard', as: :manage_dashboard
  end

  scope :business do
    get '/:slug/pending', to: 'businesses#pending', as: :business_pending
    get '/:slug', to: 'businesses#dashboard', as: :business_dashboard
    get '/:slug/subaccouts', to: 'businesses#subaccounts', as: :business_subaccounts
    get '/:slug/search_number', to: 'businesses#search_number', as: :search_number 
    post'/:slug/subaccount_number_search', to: 'businesses#search_numbers', as: :search_numbers
    get '/:slug/buy_phone_number_path', to: 'businesses#buy_phone_number', as: :buy_phone_number
    post '/:slug/send_sms', to: 'businesses#send_sms', as: :send_sms
    post '/:slug/make_a_call', to: 'businesses#make_a_call', as: :make_a_call
    get '/:slug/new_subaccount', to: 'businesses#new_subaccount', as: :new_subaccount
    post '/:slug/create_subaccount', to: 'businesses#create_subaccount', as: :create_subaccount
  end

  devise_scope :user do
    # tmp devise fix until we hook our links with javascript for :delete requests
    match 'users/sign_out' => "devise/sessions#destroy", via: [:get]
  end

  root 'welcome#index'

end
