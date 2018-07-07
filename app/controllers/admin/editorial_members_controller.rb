class Admin::EditorialMembersController < AdminController
  include ToggleableEntity
  include EntityPriority

  before_action :set_entity, except: [:index]

  # get /admin/editorial_members
  def index
    @collection = EditorialMember.list_for_administration
  end

  # get /admin/editorial_members/:id
  def show
  end

  private

  def set_entity
    @entity = EditorialMember.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find editorial_member')
    end
  end

  def restrict_access
    require_privilege :chief_editor
  end
end
