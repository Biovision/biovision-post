# frozen_string_literal: true

# News for visitors
class NewsController < ApplicationController
  before_action :set_category, only: :category
  before_action :set_entity, only: :show

  # get /news
  def index
    posts = PostType['news'].posts.for_language(current_language)
    @collection = posts.page_for_visitors(current_page)
    respond_to do |format|
      format.html
      format.json { render('posts/index') }
    end
  end

  # get /news/:category_slug
  def category
    posts = Post.in_category_branch(@category).for_language(current_language)
    @collection = posts.page_for_visitors(current_page)
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

    render 'posts/show'
  end

  # get /news/tagged/:tag_name
  def tagged
    posts = PostType['news'].posts
    @collection = posts.tagged(params[:tag_name]).page_for_visitors(current_page)
  end

  private

  def component_class
    Biovision::Components::PostsComponent
  end

  def set_category
    type = PostType['news']
    @category = type.post_categories.find_by(long_slug: params[:category_slug])
    handle_http_404('Cannot find post category (news)') if @category.nil?
  end

  def set_entity
    @entity = Post.list_for_visitors.find_by(id: params[:post_id])
    handle_http_404('Cannot find news') if @entity.nil?
  end
end
