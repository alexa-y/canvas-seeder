Rails.application.routes.draw do
  resources :batches, only: [:index, :new, :create, :show] do
    member do
      get 'output'
      get 'view_params'
    end
  end
  resources :configurations

  root to: redirect('/batches')
end
