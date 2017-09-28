class Admin::PostTypesController < AdminController
  before_action :set_entity, except: [:index]

  # get /admin/post_types
  def index
  end

  # get /admin/post_types/:id
  def show
  end

  private

  def set_entity
    @entity = PostType.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post type')
    end
  end

  def restrict_access
    require_privilege :chief_editor
  end
end
