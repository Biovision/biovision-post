# frozen_string_literal: true

# Handling post tags
class PostTagsController < AdminController
  before_action :set_entity, only: %i[edit update destroy]

  # get /post_tags/:id/edit
  def edit
  end

  # patch /post_tags/:id
  def update
    if @entity.update(entity_parameters)
      form_processed_ok(admin_post_tag_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /post_tags/:id
  def destroy
    flash[:notice] = t('post_tags.destroy.success') if @entity.destroy

    redirect_to post_tags_admin_post_type_path(id: @entity.post_type_id)
  end

  private

  def set_entity
    @entity = PostTag.find_by(id: params[:id])
    handle_http_404('Cannot find post_tag') if @entity.nil?
  end

  def restrict_access
    require_privilege_group :editors
  end

  def entity_parameters
    params.require(:post_tag).permit(PostTag.entity_parameters)
  end
end
