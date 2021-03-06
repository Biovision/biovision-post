class Admin::PostTagsController < AdminController
  before_action :set_entity, except: [:index]

  # get /admin/post_tags
  def index
    @collection = PostTag.page_for_administration(current_page)
  end

  # get /admin/post_tags/:id
  def show
  end

  # get /admin/post_tags/:id/posts
  def posts
    @collection = @entity.posts.page_for_administration(current_page)
  end

  private

  def component_class
    Biovision::Components::PostsComponent
  end

  def restrict_access
    error = 'Managing post tags is not allowed'
    handle_http_401(error) unless component_handler.allow?('chief_editor')
  end

  def set_entity
    @entity = PostTag.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post_tag')
    end
  end
end
