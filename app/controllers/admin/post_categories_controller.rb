# frozen_string_literal: true

# Handling post categories
class Admin::PostCategoriesController < AdminController
  include LockableEntity
  include ToggleableEntity
  include EntityPriority

  before_action :set_entity

  # get /admin/post_categories/:id
  def show
    @collection = @entity.posts.page_for_administration(current_page)
  end

  # put /admin/post_categories/:id/users/:user_id
  def add_user
    component_handler.user = User.find_by(id: params[:user_id])
    component_handler.allow_post_category(@entity)

    head :no_content
  end

  # delete /admin/post_categories/:id/users/:user_id
  def remove_user
    component_handler.user = User.find_by(id: params[:user_id])
    component_handler.disallow_post_category(@entity)

    head :no_content
  end

  private

  def component_slug
    Biovision::Components::PostsComponent::SLUG
  end

  def restrict_access
    error = 'Managing post categories is not allowed'
    handle_http_401(error) unless component_handler.allow?('chief_editor')
  end

  def set_entity
    @entity = PostCategory.find_by(id: params[:id])
    handle_http_404('Cannot find post category') if @entity.nil?
  end
end
