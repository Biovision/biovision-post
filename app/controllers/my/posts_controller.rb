# frozen_string_literal: true

# Post handler for user
class My::PostsController < ProfileController
  before_action :set_entity, only: %i[show edit update destroy]
  before_action :restrict_editing, only: %i[edit update destroy]

  # get /my/posts
  def index
    @collection = Post.page_for_owner(current_user, current_page)
  end

  # get /my/articles/new
  def new_article
    render_form_if_allowed 'article'
  end

  # get /my/news/new
  def new_news
    render_form_if_allowed 'news'
  end

  # get /my/blog_posts/new
  def new_blog_post
    render_form_if_allowed 'blog_post'
  end

  # post /my/posts
  def create
    @entity = Post.new(creation_parameters)
    if component_handler.allow_post_type?(@entity.post_type) && @entity.save
      apply_post_tags
      apply_post_categories
      form_processed_ok(my_post_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /my/posts/:id
  def show
  end

  # get /my/posts/:id/edit
  def edit
  end

  # patch /my/posts/:id
  def update
    if @entity.update(entity_parameters)
      apply_post_tags
      apply_post_categories
      form_processed_ok(my_post_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /my/posts/:id
  def destroy
    flash[:notice] = t('posts.destroy.success') if @entity.destroy

    redirect_to my_posts_path
  end

  # get /my/articles
  def articles
    prepare_collection 'article'
  end

  # get /my/news
  def news_index
    prepare_collection 'news'
  end

  # get /my/blog
  def blog_posts
    prepare_collection 'blog_post'
  end

  private

  def component_slug
    Biovision::Components::PostsComponent::SLUG
  end

  # @param [String] slug
  def render_form_if_allowed(slug)
    if component_handler.allow_post_type?(slug)
      @entity = PostType[slug].posts.new
      render :new
    else
      handle_http_401("User cannot create posts of type #{slug}")
    end
  end

  # @param [String] slug
  def prepare_collection(slug)
    @collection = PostType[slug].posts.page_for_owner(current_user, current_page)
  end

  def set_entity
    @entity = Post.owned_by(current_user).find_by(id: params[:id])
    handle_http_404('Cannot find post') if @entity.nil?
  end

  def restrict_editing
    handle_http_403('Entity is locked') if @entity.locked?
  end

  def entity_parameters
    params.require(:post).permit(Post.entity_parameters)
  end

  def creation_parameters
    parameters = params.require(:post).permit(Post.creation_parameters)
    parameters.merge(owner_for_entity(true))
  end

  def apply_post_tags
    @entity.tags_string = param_from_request(:tags_string)
  end

  def apply_post_categories
    if params.key?(:post_category_ids)
      @entity.post_category_ids = Array(params[:post_category_ids])
    else
      @entity.post_post_categories.destroy_all
    end
  end
end
