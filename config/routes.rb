Rails.application.routes.draw do
  apipie

  devise_for :users, controllers: { 
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  root 'home#homepage'
  get '/homepage', to: 'home#homepage'

  namespace :api do
    namespace :v1 do
      resources :users
    end
  end

  resource :avatar, only: %i[edit update destroy]

  namespace :case_managers do
    resources :cases do
      resources :notes
      resources :appointments do
        member { put :complete }
      end
      resources :communications
    end
    get '/my_appointments', to: 'appointments#my_appointments', as: 'my_appointments'
  end

  namespace :dispute_analysts do
    resources :cases do
      resources :notes
      resources :appointments do
        member { put :complete }
      end
      resources :communications
    end
    get '/my_appointments', to: 'appointments#my_appointments', as: 'my_appointments'
  end

  resources :audits, only: %i[index show]

  get '/dashboard', to: 'home#dashboard'

  resources :reports, only: %i[index post] do
    collection do
      get 'cases_details'
      get 'case_status_distribution'
      get 'case_managers_details'
      get 'dispute_analysts_details'
    end
    member do
      delete 'set_case_manager'
    end
  end
 end
