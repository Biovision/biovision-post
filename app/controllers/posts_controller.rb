# frozen_string_literal: true

# Posts management
class PostsController < ApplicationController
  before_action :restrict_access, only: %i[new create]
  before_action :set_entity, only: %i[edit update destroy]
  before_action :restrict_editing, only: %i[edit update destroy]

  layout 'admin', only: %i[new edit]

  # get /posts
  def index
    excluded = param_from_request(:x).split(',').map(&:to_i)
    @collection = Post.exclude_ids(excluded).page_for_visitors(current_page)
  end

  # post /posts
  def create
    @entity = Post.new(creation_parameters)
    if component_handler.allow_post_type?(@entity.post_type) && @entity.save
      apply_post_tags
      apply_post_categories
      add_attachments if params.key?(:post_attachment)
      mark_as_featured if params[:featured]
      form_processed_ok(@entity.url)
    else
      form_processed_with_error(:new)
    end
  end

  # get /posts/:id(-:slug)
  def show
    @entity = Post.list_for_visitors.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404("Cannot find non-deleted post #{params[:id]}")
    else
      @entity.increment :view_count
      @entity.increment :rating, 0.0025
      @entity.save
    end
  end

  # get /posts/:id/edit
  def edit
  end

  # patch /posts/:id
  def update
    if @entity.update(entity_parameters)
      apply_post_tags
      apply_post_categories
      add_attachments if params.key?(:post_attachment)
      form_processed_ok(@entity.url)
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /posts/:id
  def destroy
    flash[:notice] = t('posts.destroy.success') if @entity.destroy #@entity.update(deleted: true)

    redirect_to admin_posts_path
  end

  # get /posts/tagged/:tag_name
  def tagged
    @collection = Post.tagged(params[:tag_name]).page_for_visitors(current_page)
  end

  # get /posts/:category_slug
  def category
    posts = Post.in_category(params[:category_slug])
    @collection = posts.page_for_visitors(current_page)
    @category = @collection.first&.post_category

    handle_http_404('Cannot find post category in collection') if @category.nil?

    respond_to do |format|
      format.html
      format.json { render('posts/index') }
    end
  end

  # get /posts/search?q=
  def search
    @collection = params.key?(:q) ? search_posts(param_from_request(:q)) : []
  end

  # get /posts/rss/zen.xml
  def zen
    posts = Post.for_language(current_language).list_for_visitors
    @collection = posts.posted_after(3.days.ago)
  end

  # get /posts/rss.xml
  def rss
    posts = Post.for_language(current_language).list_for_visitors
    @collection = posts.first(20)
  end

  # get /posts/archive/(:year)(-:month)(-:day)
  def archive
    if params.key?(:day)
      archive_day
    else
      collect_dates
      archive_group if params[:year]
    end
  end

  private

  def component_class
    Biovision::Components::PostsComponent
  end

  def restrict_access
    error = 'Managing posts is not allowed'
    handle_http_401(error) unless component_handler.allow?
  end

  def set_entity
    @entity = Post.find_by(id: params[:id])
    handle_http_404('Cannot find post') if @entity.nil?
  end

  def restrict_editing
    if @entity.locked? || !component_handler.editable?(@entity)
      handle_http_403('Post is locked or not editable by current user')
    end
  end

  def entity_parameters
    params.require(:post).permit(Post.entity_parameters).merge(owner_for_post)
  end

  def creation_parameters
    parameters = params.require(:post).permit(Post.creation_parameters)
    parameters.merge(owner_for_entity(true)).merge(owner_for_post)
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

  def owner_for_post
    key    = :user_for_entity
    result = {}
    if component_handler.group?(:chief) && params.key?(key)
      result[:user_id] = param_from_request(key)
    end
    result
  end

  def collect_dates
    array  = Post.for_language(current_language).visible.published.archive
    @dates = Post.archive_dates(array)
  end

  def archive_day
    date        = Date.parse("#{params[:year]}-#{params[:month]}-#{params[:day]}")
    selection   = Post.for_language(current_language).pubdate(date)
    @collection = selection.page_for_visitors(current_page)
    render 'archive_day'
  end

  def archive_group
    year = params[:year].to_i
    @dates.select! { |k, _| k == year }
    return unless params.key?(:month)

    @dates[year]&.select! { |k, _| k == params[:month].to_i }
  end

  # @param [String] q
  def search_posts(q)
    if Post.respond_to?(:search)
      Post.search(q).records.first(50).select(&:visible_to_visitors?)
    else
      Post.pg_search(q).list_for_visitors.first(50)
    end
  end

  def add_attachments
    permitted = PostAttachment.entity_parameters
    parameters = params.require(:post_attachment).permit(permitted)

    @entity.post_attachments.create(parameters)
  end

  def mark_as_featured
    FeaturedPost.where(language: @entity.language).update_all('priority = priority + 1')
    link = FeaturedPost.new(language: @entity.language, post: @entity)
    link.priority = 1
    link.save
  end
end
