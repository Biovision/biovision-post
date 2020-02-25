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
      form_processed_ok(admin_post_category_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /post_categories/:id/edit
  def edit
  end

  # patch /post_categories/:id
  def update
    if @entity.update entity_parameters
      form_processed_ok(admin_post_category_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
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

  def component_class
    Biovision::Components::PostsComponent
  end

  def restrict_access
    error = 'Managing post categories is not allowed'
    handle_http_401(error) unless component_handler.allow?('chief_editor')
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
