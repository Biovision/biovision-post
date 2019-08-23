# frozen_string_literal: true

# Handling post categories
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
    handle_http_404('Cannot find post category') if @entity.nil?
  end

  def restrict_access
    require_privilege :chief_editor
  end
end
