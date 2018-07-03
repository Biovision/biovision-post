class Admin::PostsController < AdminController
  include ToggleableEntity

  before_action :set_entity, except: %i[index search]

  # get /admin/posts
  def index
    @collection = Post.page_for_administration(current_page)
  end

  # get /admin/posts/:id
  def show
  end

  # get /admin/posts/:id/images
  def images
    @collection = @entity.post_images.list_for_administration
  end

  # get /admin/posts/search?q=
  def search
    if params.key?(:q)
      @collection = search_posts(param_from_request(:q))
    else
      @collection = []
    end
  end

  private

  def set_entity
    @entity = Post.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post')
    end
  end

  def restrict_access
    require_privilege_group :editors
  end

  def search_posts(q)
    if Post.respond_to?(:search)
      Post.search(q).records.first(20)
    else
      Post.where('title ilike ?', "%#{q}%").list_for_administration.first(20)
    end
  end
end
