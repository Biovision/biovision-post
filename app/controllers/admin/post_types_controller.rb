# frozen_string_literal: true

# Administrative part of post type management
class Admin::PostTypesController < AdminController
  before_action :set_entity, except: [:index]

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

  private

  def component_slug
    Biovision::Components::PostsComponent::SLUG
  end

  def restrict_access
    error = 'Viewing post types is not allowed'
    handle_http_401(error) unless component_handler.allow?
  end

  def set_entity
    @entity = PostType.find_by(id: params[:id])
    handle_http_404('Cannot find post type') if @entity.nil?
  end
end
