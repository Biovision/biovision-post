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

  def component_class
    Biovision::Components::PostsComponent
  end

  def restrict_editing
    return if component_handler.editable?(@entity)

    handle_http_403("Attachment is not editable by user #{current_user&.id}")
  end

  def set_entity
    @entity = PostAttachment.find_by(id: params[:id])
    handle_http_404('Cannot find post_attachment') if @entity.nil?
  end
end
