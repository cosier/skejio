Rails.application.routes.draw do



  devise_for :users, controllers: {
    registrations: 'registrations'
  }

  scope :manage do
    resources :manage_businesses, path: 'businesses'
    resources :system_logs, only: [:index, :show]
    get '/twilio/sub_account/:sid', to: 'manage#show_twilio_account', as: :show_twilio_account
    get '/twilio/test_client', to: 'manage#show_test_client', as: :manage_test_client
    get '/businesses', to: 'manage_businesses#index', as: :businesses
    get '/', to: 'manage#dashboard', as: :manage_dashboard
  end

  controller :twilio do
    get '/twilio/voice', to: :voice, as: :twilio_voice
    get '/twilio/sms',   to: :sms, as: :twilio_sms
  end

  get '/businesses/:id/pending', to: 'businesses#pending', as: :business_pending
  get '/businesses/:id/dashboard', to: 'businesses#dashboard', as: :business_dashboard

  resources :businesses do
    get  '/buy/:number', to: 'numbers#buy_number', as: :buy_number
    post '/search', to: 'numbers#search', as: :search
    post '/send_sms', to: 'businesses#send_sms', as: :send_sms
    post '/make_a_call', to: 'businesses#make_a_call', as: :make_a_call

    resources :settings
    resources :time_sheets
    resources :time_entries
    resources :schedule_rules
    resources :break_shifts
    resources :services
    resources :offices
    resources :numbers
    resources :users
  end

  scope :api do
    resources :break_shifts
  end

  devise_scope :user do
    # tmp devise fix until we hook our links with javascript for :delete requests
    match 'users/sign_out' => "devise/sessions#destroy", via: [:get]
  end

  root 'welcome#index'

end
