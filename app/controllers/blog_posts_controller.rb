# frozen_string_literal: true

# Viewing blog posts
class BlogPostsController < ApplicationController
  before_action :set_category, only: :category
  before_action :set_entity, only: :show

  # get /blog_posts
  def index
    posts = PostType['blog_post'].posts.for_language(current_language)
    @collection = posts.page_for_visitors(current_page)
    respond_to do |format|
      format.html
      format.json { render('posts/index') }
    end
  end

  # get /blog_posts/:category_slug
  def category
    posts = Post.in_category_branch(@category).for_language(current_language)
    @collection = posts.page_for_visitors(current_page)
    respond_to do |format|
      format.html
      format.json { render('posts/index') }
    end
  end

  # get /blog_posts/:post_id-:post_slug
  def show
    @entity.increment :view_count
    @entity.increment :rating, 0.0025
    @entity.save

    render 'posts/show'
  end

  # get /blog_posts/tagged/:tag_name
  def tagged
    posts = PostType['blog_post'].posts.tagged(params[:tag_name])
    @collection = posts.page_for_visitors(current_page)
  end

  private

  def component_slug
    Biovision::Components::PostsComponent::SLUG
  end

  def set_category
    type = PostType['blog_post']
    @category = type.post_categories.find_by(long_slug: params[:category_slug])
    handle_http_404('Cannot find post category (blog_post)') if @category.nil?
  end

  def set_entity
    @entity = Post.list_for_visitors.find_by(id: params[:post_id])
    handle_http_404('Cannot find blog_post') if @entity.nil?
  end
end
