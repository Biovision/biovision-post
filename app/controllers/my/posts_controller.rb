class My::PostsController < ProfileController
  before_action :set_entity, only: [:show, :edit, :update, :destroy]

  # get /my/posts
  def index
    @collection = Post.page_for_owner(current_user, current_page)
  end

  # get /my/posts/new
  def new
    @entity = Post.new
  end

  # get /my/articles/new
  def new_article
    if current_user_has_privilege?(:editor)
      @entity = Post.of_type(:article).new
      render :new
    else
      handle_http_401('User has no editor privilege')
    end
  end

  # get /my/news/new
  def new_news
    if current_user_has_privilege?(:reporter)
      @entity = Post.of_type(:news).new
      render :new
    else
      handle_http_401('User has no reporter privilege')
    end
  end

  # get /my/blog_posts/new
  def new_blog_post
    if current_user_has_privilege?(:blogger)
      @entity = Post.of_type(:blog_post).new
      render :new
    else
      handle_http_401('User has no blogger privilege')
    end
  end

  # post /my/posts
  def create
  end

  # get /my/posts/:id
  def show
  end

  # get /my/posts/:id/edit
  def edit
  end

  # patch /my/posts/:id
  def update
  end

  # delete /my/posts/:id
  def destroy
  end

  # get /my/articles
  def articles
    @collection = Post.of_type(:article).page_for_owner(current_user, current_page)
  end

  # get /my/news
  def news_index
    @collection = Post.of_type(:news).page_for_owner(current_user, current_page)
  end

  # get /my/blog
  def blog_posts
    @collection = Post.of_type(:blog_post).page_for_owner(current_user, current_page)
  end

  private

  def set_entity
    @entity = Post.owned_by(current_user).find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post')
    end
  end
end
