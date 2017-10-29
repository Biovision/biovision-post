class Admin::PostCategoriesController < AdminController
  include LockableEntity
  include ToggleableEntity
  include EntityPriority

  before_action :set_entity

  # get /admin/post_categories/:id
  def show
    @collection = @entity.posts.page_for_administration(current_page)
  end

  private

  def set_entity
    @entity = PostCategory.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post category')
    end
  end

  def restrict_access
    require_privilege :chief_editor
  end
end
