class EditorialMembersController < AdminController
  before_action :set_entity, only: [:edit, :update, :destroy]

  # get /editorial_members/new
  def new
    @entity = EditorialMember.new
  end

  # post /editorial_members
  def create
    @entity = EditorialMember.new(creation_parameters)
    if @entity.save
      set_post_type_links
      form_processed_ok(admin_editorial_member_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /editorial_members/:id/edit
  def edit
  end

  # patch /editorial_members/:id
  def update
    if @entity.update(entity_parameters)
      set_post_type_links
      form_processed_ok(admin_editorial_member_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /editorial_members/:id
  def destroy
    flash[:notice] = t('editorial_members.destroy.success') if @entity.destroy

    redirect_to editorial_members_admin_post_type_path(id: @entity.post_type_id)
  end

  private

  def component_class
    Biovision::Components::PostsComponent
  end

  def restrict_access
    error = 'Managing editorial members is not allowed'
    handle_http_401(error) unless component_handler.allow?('chief_editor')
  end

  def set_entity
    @entity = EditorialMember.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find editorial_member')
    end
  end

  def entity_parameters
    params.require(:editorial_member).permit(EditorialMember.entity_parameters)
  end

  def creation_parameters
    params.require(:editorial_member).permit(EditorialMember.creation_parameters)
  end

  def set_post_type_links
    @entity.post_type_ids = Array(params[:post_type_ids]).map(&:to_i)
  end
end
