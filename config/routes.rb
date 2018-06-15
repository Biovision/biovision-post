Rails.application.routes.draw do
  category_slug_pattern = /[a-z]+[-_0-9a-z]*[0-9a-z]/
  post_slug_pattern     = /[a-z0-9]+[-_.a-z0-9]*[a-z0-9]+/

  resources :post_categories, :posts, :post_tags, only: [:update, :destroy]

  scope '/(:locale)', constraints: { locale: /ru|en/ } do
    resources :post_categories, except: [:index, :show, :update, :destroy]
    resources :posts, except: [:new, :update, :destroy] do
      collection do
        get 'tagged/:tag_name' => :tagged
      end
    end
    resources :post_tags, only: [:edit]

    scope :articles, controller: :articles do
      get '/' => :index, as: :articles
      get 'tagged/(:tag_name)' => :tagged, as: :tagged_articles, constraints: { tag_name: /[^\/]+/ }
      get '/:category_slug' => :category, as: :articles_category, constraints: { category_slug: category_slug_pattern }
      get '/:post_id-:post_slug' => :show, as: :show_article, constraints: { post_id: /\d+/, post_slug: post_slug_pattern }
    end

    scope :news, controller: :news do
      get '/' => :index, as: :news_index
      get 'tagged/(:tag_name)' => :tagged, as: :tagged_news, constraints: { tag_name: /[^\/]+/ }
      get '/:category_slug' => :category, as: :news_category, constraints: { category_slug: category_slug_pattern }
      get '/:post_id-:post_slug' => :show, as: :show_news, constraints: { post_id: /\d+/, post_slug: post_slug_pattern }
    end

    scope :blog_posts, controller: :blog_posts do
      get '/' => :index, as: :blog_posts
      get 'tagged/(:tag_name)' => :tagged, as: :tagged_blog_posts, constraints: { tag_name: /[^\/]+/ }
      get '/:category_slug' => :category, as: :blog_posts_category, constraints: { category_slug: category_slug_pattern }
      get '/:post_id-:post_slug' => :show, as: :show_blog_post, constraints: { post_id: /\d+/, post_slug: post_slug_pattern }
    end

    namespace :admin do
      resources :post_types, only: [:index, :show] do
        member do
          get :post_categories
          get :new_post
          get :post_tags
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
      resources :posts, only: [:index, :show] do
        member do
          put 'lock', defaults: { format: :json }
          delete 'lock', action: :unlock, defaults: { format: :json }
          post 'toggle', defaults: { format: :json }
        end
      end
      resources :post_tags, only: [:index, :show]
    end
  end
end
