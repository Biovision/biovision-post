class BlogPostsController < ApplicationController
  before_action :set_category, only: [:category]
  before_action :set_entity, only: [:show]

  # get /blog_posts
  def index
    post_type   = PostType.find_by(slug: 'blog_post')
    @collection = post_type.posts.for_language(current_language).page_for_visitors(current_page)
  end

  # get /blog_posts/:category_slug
  def category
    @collection = @category.posts.for_language(current_language).page_for_visitors(current_page)
  end

  # get /blog_posts/:post_id-:post_slug
  def show
    @entity.increment!(:view_count)
  end

  private

  def set_category
    type = PostType.find_by(slug: 'blog_post')
    @category = type.post_categories.find_by(long_slug: params[:category_slug])
    if @category.nil?
      handle_http_404('Cannot find post category (blog_post)')
    end
  end

  def set_entity
    @entity = Post.visible.find_by(id: params[:post_id])
    if @entity.nil?
      handle_http_404('Cannot find blog_post')
    end
  end
end
