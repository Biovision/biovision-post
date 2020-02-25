# frozen_string_literal: true

# Administrative part of post group categories list management
class Admin::PostGroupCategoriesController < AdminController
  include EntityPriority

  before_action :set_entity

  private

  def component_class
    Biovision::Components::PostsComponent
  end

  def restrict_access
    error = 'Managing post group categories is not allowed'
    handle_http_401(error) unless component_handler.allow?('chief_editor')
  end

  def set_entity
    @entity = PostGroupCategory.find_by(id: params[:id])
    handle_http_404('Cannot find post_group_category') if @entity.nil?
  end
end
