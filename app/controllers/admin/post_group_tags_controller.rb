# frozen_string_literal: true

# Administrative part of post group tags list management
class Admin::PostGroupTagsController < AdminController
  include EntityPriority

  before_action :set_entity

  private

  def set_entity
    @entity = PostGroupTag.find_by(id: params[:id])
    handle_http_404('Cannot find post_group_tag') if @entity.nil?
  end

  def restrict_access
    require_privilege :chief_editor
  end
end
