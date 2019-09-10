# frozen_string_literal: true

# Controller for deleting post attachments
class PostAttachmentsController < AdminController
  before_action :set_entity, only: :destroy
  before_action :restrict_editing, only: :destroy

  # delete /post_attachments/:id
  def destroy
    @entity.destroy

    redirect_to(admin_post_path(id: @entity.post_id))
  end

  private

  def component_slug
    Biovision::Components::PostsComponent::SLUG
  end

  def restrict_access
    error = 'Managing post attachments is not allowed'
    handle_http_401(error) unless component_handler.allow?
  end

  def restrict_editing
    return if @entity.editable_by?(current_user)

    handle_http_403("Attachment is not editable by user #{current_user&.id}")
  end

  def set_entity
    @entity = PostAttachment.find_by(id: params[:id])
    handle_http_404('Cannot find post_attachment') if @entity.nil?
  end
end
