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
      next_page = PostManager.handler(@entity).post_path
      respond_to do |format|
        format.html { redirect_to next_page }
        format.json { render json: { links: { self: next_page } } }
        format.js { render js: "document.location.href = '#{next_page}'" }
      end
    else
      render :new, status: :bad_request
    end
  end

  # get /posts/:id
  def show
    @entity = Post.find_by(id: params[:id], visible: true, deleted: false)
    if @entity.nil?
      handle_http_404("Cannot find non-deleted post #{params[:id]}")
    end
  end

  # get /posts/:id/edit
  def edit
  end

  # patch /posts/:id
  def update
    if @entity.update(entity_parameters)
      next_page = PostManager.handler(@entity).post_path
      respond_to do |format|
        format.html { redirect_to next_page }
        format.json { render json: { links: { self: next_page } } }
        format.js { render js: "document.location.href = '#{next_page}'" }
      end
    else
      render :edit, status: :bad_request
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
