class Admin::FeaturedPostsController < AdminController
  include EntityPriority

  before_action :set_entity, except: :index

  # get /admin/featured_posts
  def index
    @languages = Language.active.ordered_by_priority
  end

  private

  def set_entity
    @entity = FeaturedPost.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post_link')
    end
  end

  def restrict_access
    require_privilege :chief_editor
  end
end
