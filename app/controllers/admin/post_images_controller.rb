class Admin::PostImagesController < AdminController
  include ToggleableEntity
  include EntityPriority

  before_action :set_entity, except: [:index]

  # get /admin/post_images
  def index
    @collection = PostImage.page_for_administration(current_page)
  end

  # get /admin/post_images/:id
  def show
  end

  # get /admin/post_images/:id/posts
  def posts
    @collection = @entity.posts.page_for_administration(current_page)
  end

  private

  def set_entity
    @entity = PostImage.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post_image')
    end
  end

  def restrict_access
    require_privilege_group :editors
  end
end
