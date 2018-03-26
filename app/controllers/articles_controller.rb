class ArticlesController < ApplicationController
  before_action :set_category, only: [:category]
  before_action :set_entity, only: [:show]

  # get /articles
  def index
    post_type   = PostType.find_by(slug: 'article')
    @collection = post_type.posts.for_language(current_language).page_for_visitors(current_page)
  end

  # get /articles/:category_slug
  def category
    @collection = @category.posts.for_language(current_language).page_for_visitors(current_page)
  end

  # get /articles/:post_id-:post_slug
  def show
    @entity.increment!(:view_count)
  end

  private

  def set_category
    type      = PostType.find_by(slug: 'article')
    @category = type.post_categories.find_by(long_slug: params[:category_slug])
    if @category.nil?
      handle_http_404('Cannot find post category (article)')
    end
  end

  def set_entity
    @entity = Post.visible.find_by(id: params[:post_id])
    if @entity.nil?
      handle_http_404('Cannot find article')
    end
  end
end
