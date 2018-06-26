class My::PostsController < ProfileController
  # get /my/posts
  def index
    @collection = Post.list_for_owner(current_user)
  end

  # get /my/posts/new
  def new
    @entity = Post.new
  end

  # post /my/posts
  def create
  end

  # get /my/posts/:id
  def show
  end
end
