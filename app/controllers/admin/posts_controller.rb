class Admin::PostsController < AdminController
  before_action :set_entity, except: [:index]

  # get /admin/posts
  def index
    @collection = Post.page_for_administration(current_page)
  end

  # get /admin/posts/:id
  def show
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
end
