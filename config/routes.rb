Rails.application.routes.draw do
  category_slug_pattern = /[a-z]+[-_0-9a-z]*[0-9a-z]/
  post_slug_pattern     = /[a-z0-9]+[-_.a-z0-9]*[a-z0-9]+/

  resources :post_categories, except: [:index, :show]
  resources :posts, except: [:new]

  scope :articles, controller: :articles do
    get '/' => :index, as: :articles
    get '/:category_slug' => :category, as: :articles_category, constraints: { category_slug: category_slug_pattern }
    get '/:post_id-:post_slug' => :show, as: :show_article, constraints: { post_id: /\d+/, post_slug: post_slug_pattern }
  end

  scope :news, controller: :news do
    get '/' => :index, as: :news_index
    get '/:category_slug' => :category, as: :news_category, constraints: { category_slug: category_slug_pattern }
    get '/:post_id-:post_slug' => :show, as: :show_news, constraints: { post_id: /\d+/, post_slug: post_slug_pattern }
  end

  scope :blog_posts, controller: :blog_posts do
    get '/' => :index, as: :blog_posts
    get '/:category_slug' => :category, as: :blog_posts_category, constraints: { category_slug: category_slug_pattern }
    get '/:post_id-:post_slug' => :show, as: :show_blog_post, constraints: { post_id: /\d+/, post_slug: post_slug_pattern }
  end

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
    resources :posts, only: [:index, :show] do
      member do
        put 'lock', defaults: { format: :json }
        delete 'lock', action: :unlock, defaults: { format: :json }
        post 'toggle', defaults: { format: :json }
      end
    end
  end
end
