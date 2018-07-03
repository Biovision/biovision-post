class PostLinksController < AdminController
  before_action :set_entity, only: :destroy

  # post /post_links
  def create
    @entity = PostLink.new(entity_parameters)
    if @entity.save
      render status: :created
    else
      render json: { errors: @entity.errors }, status: :bad_request
    end
  end

  # delete /post_links/:id
  def destroy
    @entity.destroy

    head :no_content
  end

  private

  def restrict_access
    require_privilege_group :editors
  end

  def entity_parameters
    params.require(:post_link).permit(PostLink.creation_parameters)
  end

  def set_entity
    @entity = PostLink.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post_link')
    end
  end
end
