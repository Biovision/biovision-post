class Admin::PostLinksController < AdminController
  include ToggleableEntity
  include EntityPriority

  before_action :set_entity

  private

  def component_class
    Biovision::Components::PostsComponent
  end

  def set_entity
    @entity = PostLink.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post_link')
    end
  end
end
