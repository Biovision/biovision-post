# frozen_string_literal: true

# Administrative part for managing editorial members
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

  # put /admin/editorial_members/:id/post_types/:post_type_id
  def add_post_type
    @entity.add_post_type(PostType.find_by(id: params[:post_type_id]))

    head :no_content
  end

  # delete /admin/editorial_members/:id/post_types/:post_type_id
  def remove_post_type
    @entity.remove_post_type(PostType.find_by(id: params[:post_type_id]))

    head :no_content
  end

  private

  def component_slug
    Biovision::Components::PostsComponent::SLUG
  end

  def restrict_access
    error = 'Managing editorial members is not allowed'
    handle_http_401(error) unless component_handler.allow?('chief_editor')
  end

  def set_entity
    @entity = EditorialMember.find_by(id: params[:id])
    handle_http_404('Cannot find editorial_member') if @entity.nil?
  end
end
