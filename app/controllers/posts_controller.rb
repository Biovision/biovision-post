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
    if @entity.save
      apply_post_tags
      PostBodyParserJob.perform_later(@entity.id)
      form_processed_ok(PostManager.new(@entity).post_path)
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
      PostBodyParserJob.perform_later(@entity.id)
      form_processed_ok(PostManager.new(@entity).post_path)
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

  # get /posts/tagged/:tag_name
  def tagged
    @collection = Post.tagged(params[:tag_name]).page_for_visitors(current_page)
  end

  # get /posts/:category_slug
  def category
    @collection = Post.in_category(params[:category_slug]).page_for_visitors(current_page)
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
    @collection = Post.for_language(current_language).list_for_visitors.posted_after(3.days.ago)
  end

  # get /posts/rss.xml
  def rss
    @collection = Post.for_language(current_language).list_for_visitors.first(20)
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

  def set_entity
    @entity = Post.find_by(id: params[:id])
    handle_http_404('Cannot find post') if @entity.nil?
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
    params.require(:post).permit(Post.entity_parameters).merge(owner_for_post)
  end

  def creation_parameters
    parameters = params.require(:post).permit(Post.creation_parameters)
    parameters.merge(owner_for_entity(true)).merge(owner_for_post)
  end

  def apply_post_tags
    @entity.tags_string = param_from_request(:tags_string)
  end

  def owner_for_post
    key    = :user_for_entity
    result = {}
    if current_user_has_privilege?(:chief_editor) && params.key?(key)
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
      Post.where('title ilike ?', "%#{q}%").list_for_visitors.first(50)
    end
  end
end
