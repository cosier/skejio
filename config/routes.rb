Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'registrations'
  }

  scope :business do
    get '/:slug/pending', to: 'businesses#pending', as: :business_pending
    get '/:slug', to: 'businesses#dashboard', as: :business_dashboard
  end

  devise_scope :user do
    # tmp devise fix until we hook our links with javascript for :delete requests
    match 'users/sign_out' => "devise/sessions#destroy", via: [:get]
  end

  root 'welcome#index'

end
