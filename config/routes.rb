Rails.application.routes.draw do
  resources :post_categories, except: [:index, :show]
  resources :posts
  resources :articles

  namespace :admin do
    resources :post_types, only: [:index, :show] do
      member do
        get :post_categories
        get :new_post
      end
    end
    resources :post_categories, only: [:show] do
      member do
        put 'lock', defaults: { format: :json }
        delete 'lock', action: :unlock, defaults: { format: :json }
        post 'priority', defaults: { format: :json }
        post 'toggle', defaults: { format: :json }
      end
    end
    resources :posts, only: [:index, :show]
  end
end
