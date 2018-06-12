class PostsController < ApplicationController
  before_action :restrict_access, only: [:new, :create]
  before_action :set_entity, only: [:edit, :update, :destroy]
  before_action :restrict_editing, only: [:edit, :update, :destroy]

  layout 'admin', only: [:new, :edit]

  # get /posts
  def index
    @collection = Post.page_for_visitors(current_page)
  end

  # post /posts
  def create
    @entity = Post.new(creation_parameters)
    if @entity.save
      form_processed_ok(PostManager.handler(@entity).post_path)
    else
      form_processed_with_error(:new)
    end
  end

  # get /posts/:id
  def show
    @entity = Post.list_for_visitors.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404("Cannot find non-deleted post #{params[:id]}")
    else
      @entity.increment! :view_count
    end
  end

  # get /posts/:id/edit
  def edit
  end

  # patch /posts/:id
  def update
    if @entity.update(entity_parameters)
      form_processed_ok(PostManager.handler(@entity).post_path)
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /posts/:id
  def destroy
    if @entity.destroy #@entity.update(deleted: true)
      flash[:notice] = t('posts.destroy.success')
    end
    redirect_to admin_posts_path
  end

  private

  def set_entity
    @entity = Post.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post')
    end
  end

  def restrict_access
    require_privilege_group :editors
  end

  def restrict_editing
    if @entity.locked? || !@entity.editable_by?(current_user)
       handle_http_403('Post is locked or not editable by current user')
    end
  end

  def entity_parameters
    params.require(:post).permit(Post.entity_parameters)
  end

  def creation_parameters
    parameters = params.require(:post).permit(Post.creation_parameters)
    parameters.merge(owner_for_entity(true))
  end
end
