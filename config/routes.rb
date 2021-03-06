# frozen_string_literal: true

Rails.application.routes.draw do
  category_slug_pattern = /[a-z]+[-_0-9a-z]*[0-9a-z]/
  post_slug_pattern = /[a-z0-9]+[-_.a-z0-9]*[a-z0-9]+/
  archive_constraints = { year: /19\d\d|2[01]\d\d/, month: /0[1-9]|1[0-2]/, day: /0[1-9]|[12]\d|3[01]/ }

  concern :priority do
    post :priority, on: :member, defaults: { format: :json }
  end

  concern :toggle do
    post :toggle, on: :member, defaults: { format: :json }
  end

  concern :check do
    post :check, on: :collection, defaults: { format: :json }
  end

  concern :lock do
    member do
      put :lock, defaults: { format: :json }
      delete :lock, action: :unlock, defaults: { format: :json }
    end
  end

  resources :post_categories, :posts, :post_tags, :post_images, only: %i[update destroy]
  resources :post_links, only: :destroy
  resources :editorial_members, only: %i[update destroy]
  resources :featured_posts, only: :destroy
  resources :post_illustrations, only: :create
  resources :post_groups, only: %i[update destroy]
  resources :post_attachments, only: :destroy

  scope '/(:locale)', constraints: { locale: /ru|en|sv|cn/ } do
    resources :post_categories, except: %i[index show update destroy]
    resources :posts, except: %i[new update destroy] do
      collection do
        get 'search'
        get 'categories/:category_slug' => :category, as: :posts_category, constraints: { category_slug: category_slug_pattern }
        get 'tagged/(:tag_name)' => :tagged, as: :tagged, constraints: { tag_name: /[^\/]+?/ }
        get 'archive/(:year)(-:month)(-:day)' => :archive, as: :archive, constraints: archive_constraints
        get 'rss/zen.xml' => :zen, defaults: { format: :xml }
        get 'rss.xml' => :rss, as: :rss, defaults: { format: :xml }
        get ':category_slug' => :category, as: :short_category, constraints: { category_slug: category_slug_pattern }
        get ':id-:slug' => :show, constraints: { id: /\d+/, slug: post_slug_pattern }
      end
    end
    resources :post_tags, only: :edit
    resources :post_images, only: %i[edit create]
    resources :post_links, only: :create
    resources :editorial_members, only: %i[new create edit]
    resources :featured_posts, only: :create
    resources :post_groups, only: %i[show new create edit], concerns: :check

    scope :articles, controller: :articles do
      get '/' => :index, as: :articles
      get 'new' => :new, as: :new_article
      get 'archive/(:year)(-:month)(-:day)' => :archive, as: :articles_archive, constraints: archive_constraints
      get 'tagged/(:tag_name)' => :tagged, as: :tagged_articles, constraints: { tag_name: /[^\/]+?/ }
      get '/:category_slug' => :category, as: :articles_category, constraints: { category_slug: category_slug_pattern }
      get '/:post_id-:post_slug' => :show, as: :show_article, constraints: { post_id: /\d+/, post_slug: post_slug_pattern }
    end

    scope :news, controller: :news do
      get '/' => :index, as: :news_index
      get 'new' => :new, as: :new_news
      get 'archive/(:year)(-:month)(-:day)' => :archive, as: :news_archive, constraints: archive_constraints
      get 'tagged/(:tag_name)' => :tagged, as: :tagged_news, constraints: { tag_name: /[^\/]+?/ }
      get '/:category_slug' => :category, as: :news_category, constraints: { category_slug: category_slug_pattern }
      get '/:post_id-:post_slug' => :show, as: :show_news, constraints: { post_id: /\d+/, post_slug: post_slug_pattern }
    end

    scope :blog_posts, controller: :blog_posts do
      get '/' => :index, as: :blog_posts
      get 'new' => :new, as: :new_blog_post
      get 'archive/(:year)(-:month)(-:day)' => :archive, as: :blog_posts_archive, constraints: archive_constraints
      get 'tagged/(:tag_name)' => :tagged, as: :tagged_blog_posts, constraints: { tag_name: /[^\/]+?/ }
      get '/:category_slug' => :category, as: :blog_posts_category, constraints: { category_slug: category_slug_pattern }
      get '/:post_id-:post_slug' => :show, as: :show_blog_post, constraints: { post_id: /\d+/, post_slug: post_slug_pattern }
    end

    scope :authors, controller: 'authors' do
      get '/' => :index, as: :authors
      get ':slug' => :show, as: :author
    end

    scope 'u/:slug', controller: :profiles, constraints: { slug: %r{[^/]+} } do
      get 'posts' => :posts, as: :user_posts
    end

    namespace :admin do
      resources :post_types, only: %i[index show] do
        member do
          get :post_categories
          get :new_post
          get :post_tags
          get :authors
          put 'users/:user_id' => :add_user, as: :user
          delete 'users/:user_id' => :remove_user
        end
      end

      resources :post_categories, only: :show, concerns: %i[toggle priority] do
        member do
          put 'users/:user_id' => :add_user, as: :user
          delete 'users/:user_id' => :remove_user
        end
      end

      resources :posts, only: %i[index show], concerns: %i[lock toggle] do
        get 'search', on: :collection
        get 'images', on: :member
      end

      resources :post_tags, only: %i[index show] do
        get 'posts', on: :member
      end

      resources :post_illustrations, only: %i[index show]
      resources :post_images, only: %i[index show], concerns: %i[toggle priority]

      resources :post_groups, only: %i[index show], concerns: %i[toggle priority] do
        member do
          put 'categories/:category_id' => :add_category, as: :category
          delete 'categories/:category_id' => :remove_category
          put 'tags/:tag_id' => :add_tag, as: :tag
          delete 'tags/:tag_id' => :remove_tag
          get :tags, defaults: { format: :json }
        end
      end
      scope 'post_group_categories/:id', controller: :post_group_categories do
        post 'priority' => :priority, as: :priority_post_group_category, defaults: { format: :json }
      end
      scope 'post_group_tags/:id', controller: :post_group_tags do
        post 'priority' => :priority, as: :priority_post_group_tag, defaults: { format: :json }
      end

      resources :editorial_members, only: %i[index show], concerns: %i[toggle priority] do
        member do
          put 'post_types/:post_type_id' => :add_post_type, as: :post_type
          delete 'post_types/:post_type_id' => :remove_post_type
        end
      end

      resources :featured_posts, only: :index, concerns: :priority

      scope 'post_links', controller: :post_links do
        post ':id/priority' => :priority, as: :priority_post_link, defaults: { format: :json }
      end
    end

    namespace :my do
      get 'articles' => 'posts#articles'
      get 'news' => 'posts#news_index'
      get 'blog' => 'posts#blog_posts'
      get 'articles/new' => 'posts#new_article', as: :new_article
      get 'news/new' => 'posts#new_news', as: :new_news
      get 'blog_posts/new' => 'posts#new_blog_post', as: :new_blog_post

      resources :posts, except: :new
    end
  end
end
