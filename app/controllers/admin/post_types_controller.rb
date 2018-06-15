class Admin::PostTypesController < AdminController
  before_action :set_entity, except: [:index]

  # get /admin/post_types
  def index
    @collection = PostType.page_for_administration
  end

  # get /admin/post_types/:id
  def show
    @collection = @entity.posts.page_for_administration(current_page)
  end

  # get /admin/post_types/:id/post_categories
  def post_categories
  end

  # get /admin/post_types/:id/post_tags
  def post_tags
    @collection = @entity.post_tags.page_for_administration(current_page)
  end

  private

  def set_entity
    @entity = PostType.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post type')
    end
  end

  def restrict_access
    require_privilege_group :editors
  end
end
