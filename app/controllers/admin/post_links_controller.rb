class Admin::PostLinksController < AdminController
  include ToggleableEntity
  include EntityPriority

  before_action :set_entity

  private

  def set_entity
    @entity = PostLink.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post_link')
    end
  end

  def restrict_access
    require_privilege_group :editors
  end
end
