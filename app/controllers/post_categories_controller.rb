class PostCategoriesController < AdminController
  before_action :set_entity, only: [:edit, :update, :destroy]
  before_action :restrict_editing, only: [:edit, :update, :destroy]

  # get /post_categories/new
  def new
    @entity = PostCategory.new
  end

  # post /post_categories
  def create
    @entity = PostCategory.new(creation_parameters)
    if @entity.save
      next_page = admin_post_category_path(id: @entity.id)
      respond_to do |format|
        format.html { redirect_to(next_page) }
        format.json { render json: { links: { self: next_page } } }
        format.js { render(js: "document.location.href = '#{next_page}'") }
      end
    else
      render :new, status: :bad_request
    end
  end

  # get /post_categories/:id/edit
  def edit
  end

  # patch /post_categories/:id
  def update
    if @entity.update entity_parameters
      next_page = admin_post_category_path(id: @entity.id)
      respond_to do |format|
        format.html { redirect_to(next_page, notice: t('post_categories.update.success')) }
        format.json { render json: { links: { self: next_page } } }
        format.js { render(js: "document.location.href = '#{next_page}'") }
      end
    else
      render :edit, status: :bad_request
    end
  end

  # delete /post_categories/:id
  def destroy
    if @entity.destroy
      flash[:notice] = t('post_categories.destroy.success')
    end
    redirect_to(post_categories_admin_post_type_path(id: @entity.post_type_id))
  end

  protected

  def restrict_access
    require_privilege :chief_editor
  end

  def restrict_editing
    if @entity.locked?
      redirect_to admin_post_category_path(id: @entity.id), alert: t('post_categories.edit.forbidden')
    end
  end

  def set_entity
    @entity = PostCategory.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post_category')
    end
  end

  def entity_parameters
    params.require(:post_category).permit(PostCategory.entity_parameters)
  end

  def creation_parameters
    params.require(:post_category).permit(PostCategory.creation_parameters)
  end
end
