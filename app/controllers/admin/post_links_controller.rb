class Admin::PostLinksController < AdminController
  include ToggleableEntity
  include EntityPriority

  before_action :set_entity

  private

  def component_slug
    Biovision::Components::PostsComponent::SLUG
  end

  def restrict_access
    error = 'Managing post links is not allowed'
    handle_http_401(error) unless component_handler.allow?
  end

  def set_entity
    @entity = PostLink.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post_link')
    end
  end
end
