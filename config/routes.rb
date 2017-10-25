Rails.application.routes.draw do


  namespace :admin do
    resources :post_types, only: [:index, :show]
    resources :posts, only: [:index, :show]
  end
end
