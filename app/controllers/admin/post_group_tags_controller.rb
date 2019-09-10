# frozen_string_literal: true

# Administrative part of post group tags list management
class Admin::PostGroupTagsController < AdminController
  include EntityPriority

  before_action :set_entity

  private

  def component_slug
    Biovision::Components::PostsComponent::SLUG
  end

  def restrict_access
    error = 'Managing post tags is not allowed'
    handle_http_401(error) unless component_handler.allow?('chief_editor')
  end

  def set_entity
    @entity = PostGroupTag.find_by(id: params[:id])
    handle_http_404('Cannot find post_group_tag') if @entity.nil?
  end
end
