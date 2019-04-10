# frozen_string_literal: true

# Administrative part of post group management
class Admin::PostGroupsController < AdminController
  include EntityPriority
  include ToggleableEntity

  before_action :set_entity, except: :index

  # get /admin/post_groups
  def index
    @collection = PostGroup.list_for_administration
  end

  # get /admin/post_groups/:id
  def show
  end

  # put /admin/post_groups/:id/categories/:category_id
  def add_category
    @entity.add_category(PostCategory.find_by(id: params[:category_id]))

    head :no_content
  end

  # get /admin/post_groups/:id/tags?q=
  def tags
    @collection = PostTag.with_name_like(params[:q]).list_for_administration.first(50)
  end

  # delete /admin/post_groups/:id/categories/:category_id
  def remove_category
    @entity.remove_category(PostCategory.find_by(id: params[:category_id]))

    head :no_content
  end

  # put /admin/post_groups/:id/tags/:tag_id
  def add_tag
    @entity.add_tag(PostTag.find_by(id: params[:tag_id]))

    head :no_content
  end

  # delete /admin/post_groups/:id/tags/:tag_id
  def remove_tag
    @entity.remove_tag(PostTag.find_by(id: params[:tag_id]))

    head :no_content
  end

  private

  def set_entity
    @entity = PostGroup.find_by(id: params[:id])
    handle_http_404('Cannot find post_group') if @entity.nil?
  end

  def restrict_access
    require_privilege :chief_editor
  end
end
