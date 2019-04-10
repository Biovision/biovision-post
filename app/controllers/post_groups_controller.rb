# frozen_string_literal: true

# Handling post groups
class PostGroupsController < ApplicationController
  before_action :restrict_access, except: :show
  before_action :set_entity, only: %i[edit update destroy]

  layout 'admin', except: :show

  # post /post_groups/check
  def check
    @entity = PostGroup.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # get /post_groups/new
  def new
    @entity = PostGroup.new
  end

  # post /post_groups
  def create
    @entity = PostGroup.new(entity_parameters)
    if @entity.save
      form_processed_ok(admin_post_group_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /post_groups/:id/edit
  def edit
  end

  # patch /post_groups/:id
  def update
    if @entity.update(entity_parameters)
      form_processed_ok(admin_post_group_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /post_groups/:id
  def destroy
    flash[:notice] = t('post_groups.destroy.success') if @entity.destroy

    redirect_to post_groups_admin_post_type_path(id: @entity.post_type_id)
  end

  # get /post_groups/:id
  def show
    @entity = PostGroup.visible.find_by(slug: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post_group')
    else
      @collection = @entity.posts_page(current_page)
    end
  end

  private

  def set_entity
    @entity = PostGroup.find_by(id: params[:id])
    handle_http_404('Cannot find post_group') if @entity.nil?
  end

  def restrict_access
    require_privilege :chief_editor
  end

  def entity_parameters
    params.require(:post_group).permit(PostGroup.entity_parameters)
  end
end
