Rails.application.routes.draw do



  devise_for :users, controllers: {
    registrations: 'registrations'
  }

  scope :manage do
    resources :manage_businesses, path: 'businesses'

    resources :system_logs, only: [:index, :show] do
      collection do
        get '/clear/logs', to: :clear_logs, as: :clear
        get '/clear/customers', to: :clear_customers, as: :clear_customers
        get '/clear/sessions', to: :clear_sessions, as: :clear_sessions
        get '/clear/everything', to: :clear_everything, as: :clear_everything
      end
    end

    get '/twilio/sub_account/:sid', to: 'manage#show_twilio_account', as: :show_twilio_account
    get '/twilio/stats', to: 'manage#show_twilio_stats', as: :manage_twilio_stats
    get '/twilio/test_client', to: 'manage#show_test_client', as: :manage_test_client

    get '/businesses', to: 'manage_businesses#index', as: :businesses
    get '/', to: 'manage#dashboard', as: :manage_dashboard
  end

  # Live handling of Customer Scheduler Sessions
  controller :live_scheduler do
    match '/twilio/voice', to: :voice, as: :twilio_voice, via: [:get, :post]
    match '/twilio/sms',   to: :sms, as: :twilio_sms, via: [:get, :post]
  end

  # Live handling of Customer Dynamic Tree Sessions
  controller :live_dynamo do
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
    resources :businesses do
      resources :services
      resources :offices
    end
  end

  devise_scope :user do
    # tmp devise fix until we hook our links with javascript for :delete requests
    match 'users/sign_out' => "devise/sessions#destroy", via: [:get]
  end

  root 'welcome#index'

end
