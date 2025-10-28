Rails.application.routes.draw do
  # Root
  root 'pages#home'

  # Authentication
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'signup', to: 'registrations#new'
  post 'signup', to: 'registrations#create'
  get 'verify_otp', to: 'registrations#verify_otp'
  post 'verify_otp', to: 'registrations#confirm_otp'

  # Patient namespace
  namespace :patients do
    resource :dashboard, only: [:show]
  end

  # Doctor namespace
  namespace :doctors do
    resource :dashboard, only: [:show]
    resource :profile, only: [:edit, :update]
    resources :appointment_slots
    resource :qr_code, only: [:show] do
      get :download
      get :generate_image
    end
  end

  # Admin namespace
  namespace :admin do
    resource :dashboard, only: [:show]
    resources :users do
      member do
        post :verify
      end
    end
    resources :symptom_reports, only: [:index, :show]
    resources :appointments, only: [:index, :show]
    resources :audit_logs, only: [:index]
  end

  # Public resources
  resources :doctors, only: [:index, :show], param: :slug do
    resources :reviews, only: [:create]
  end
  resources :symptom_reports, only: [:new, :create, :show]

  # Appointments
  resources :appointments do
    member do
      get :payment_confirm
      post :payment_confirm
    end
  end

  # Test orders and results
  resources :test_orders, only: [:index, :show, :create]
  resources :test_result_uploads, only: [:new, :create, :show] do
    member do
      post :review
    end
  end

  # Notifications
  resources :notifications, only: [:index] do
    member do
      post :mark_read
    end
    collection do
      post :mark_all_read
    end
  end

  # Messages
  resources :messages, only: [:index, :create] do
    member do
      post :mark_as_read
    end
  end

  # API routes
  namespace :api do
    get 'autocomplete/doctors', to: 'autocomplete#doctors'
    get 'autocomplete/specializations', to: 'autocomplete#specializations'
  end

  # Health check
  get 'up', to: 'rails/health#show', as: :rails_health_check
end
