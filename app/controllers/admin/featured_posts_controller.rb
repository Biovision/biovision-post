class Admin::FeaturedPostsController < AdminController
  include EntityPriority

  before_action :set_entity, except: :index

  # get /admin/featured_posts
  def index
    @languages = Language.active.ordered_by_priority
  end

  private

  def component_class
    Biovision::Components::PostsComponent
  end

  def restrict_access
    error = 'Managing post groups is not allowed'
    handle_http_401(error) unless component_handler.allow?('chief_editor', 'deputy_chief_editor')
  end

  def set_entity
    @entity = FeaturedPost.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post_link')
    end
  end
end
