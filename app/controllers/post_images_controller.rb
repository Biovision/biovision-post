# frozen_string_literal: true

# Managing post images
class PostImagesController < AdminController
  before_action :set_entity, only: [:edit, :update, :destroy]
  before_action :restrict_editing, only: [:edit, :update, :destroy]

  # post /post_images
  def create
    @entity = PostImage.new(creation_parameters)
    if @entity.save
      form_processed_ok(images_admin_post_path(id: @entity.post_id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /post_images/:id/edit
  def edit
  end

  # patch /post_images/:id
  def update
    if @entity.update(entity_parameters)
      form_processed_ok(admin_post_image_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /post_images/:id
  def destroy
    if @entity.destroy
      flash[:notice] = t('post_images.destroy.success')
    end
    redirect_to admin_post_path(id: @entity.post_id)
  end

  private

  def component_slug
    Biovision::Components::PostsComponent::SLUG
  end

  def set_entity
    @entity = PostImage.find_by(id: params[:id])
    handle_http_404('Cannot find post_image') if @entity.nil?
  end

  def restrict_editing
    unless component_handler.editable?(@entity.post)
      handle_http_401('Post image is not editable by current user')
    end
  end

  def entity_parameters
    params.require(:post_image).permit(PostImage.entity_parameters)
  end

  def creation_parameters
    params.require(:post_image).permit(PostImage.creation_parameters)
  end
end
