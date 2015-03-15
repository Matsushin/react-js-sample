Rails.application.routes.draw do
  root to: 'dashboard#index'

  namespace 'api' do
    resources :comments, only: %i( index create destroy)
  end
end
