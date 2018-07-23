class NewsController < ApplicationController
  before_action :set_category, only: :category
  before_action :set_entity, only: :show

  # get /news
  def index
    post_type   = PostType.find_by(slug: 'news')
    @collection = post_type.posts.for_language(current_language).page_for_visitors(current_page)
    respond_to do |format|
      format.html
      format.json { render('posts/index') }
    end
  end

  # get /news/:category_slug
  def category
    @collection = @category.posts.for_language(current_language).page_for_visitors(current_page)
    respond_to do |format|
      format.html
      format.json { render('posts/index') }
    end
  end

  # get /news/:post_id-:post_slug
  def show
    @entity.increment :view_count
    @entity.increment :rating, 0.0025
    @entity.save
  end

  # get /news/tagged/:tag_name
  def tagged
    post_type   = PostType.find_by(slug: 'news')
    @collection = post_type.posts.tagged(params[:tag_name]).page_for_visitors(current_page)
  end

  private

  def set_category
    type      = PostType.find_by(slug: 'news')
    @category = type.post_categories.find_by(long_slug: params[:category_slug])
    if @category.nil?
      handle_http_404('Cannot find post category (news)')
    end
  end

  def set_entity
    @entity = Post.list_for_visitors.find_by(id: params[:post_id])
    if @entity.nil?
      handle_http_404('Cannot find news')
    end
  end
end
