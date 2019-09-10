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

  def component_slug
    Biovision::Components::PostsComponent::SLUG
  end

  def restrict_access
    error = 'Viewing post images is not allowed'
    handle_http_401(error) unless component_handler.allow?
  end

  def set_entity
    @entity = PostImage.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post_image')
    end
  end
end
