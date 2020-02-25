# frozen_string_literal: true

# Administrative part of post type management
class Admin::PostTypesController < AdminController
  before_action :set_entity, except: :index
  before_action :restrict_post_type, only: %i[new_post]

  # get /admin/post_types
  def index
    @collection = PostType.page_for_administration
  end

  # get /admin/post_types/:id
  def show
    @filter = params[:filter] || {}
    @collection = @entity.posts.page_for_administration(current_page, @filter)
  end

  # get /admin/post_types/:id/post_categories
  def post_categories
  end

  # get /admin/post_types/:id/post_tags
  def post_tags
    @collection = @entity.post_tags.page_for_administration(current_page)
  end

  # get /admin/post_types/:id/authors
  def authors
    @collection = @entity.editorial_members.list_for_administration
  end

  # get /admin/post_types/:id/new_post
  def new_post
  end

  # put /admin/post_types/:id/users/:user_id
  def add_user
    if component_handler.allow?('chief_editor')
      component_handler.user = User.find_by(id: params[:user_id])
      component_handler.allow_post_type(@entity)
    end

    head :no_content
  end

  # delete /admin/post_types/:id/users/:user_id
  def remove_user
    if component_handler.allow?('chief_editor')
      component_handler.user = User.find_by(id: params[:user_id])
      component_handler.disallow_post_type(@entity)
    end

    head :no_content
  end

  private

  def component_class
    Biovision::Components::PostsComponent
  end

  def restrict_post_type
    error = 'Handling this post type is not allowed'
    handle_http_401(error) unless component_handler.allow_post_type?(@entity)
  end

  def set_entity
    @entity = PostType.find_by(id: params[:id])
    handle_http_404('Cannot find post type') if @entity.nil?
  end
end
