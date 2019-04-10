# frozen_string_literal: true

# Administrative part of post group categories list management
class Admin::PostGroupCategoriesController < AdminController
  include EntityPriority

  before_action :set_entity

  private

  def set_entity
    @entity = PostGroupCategory.find_by(id: params[:id])
    handle_http_404('Cannot find post_group_category') if @entity.nil?
  end

  def restrict_access
    require_privilege :chief_editor
  end
end
