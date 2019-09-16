# frozen_string_literal: true

# Displaying post authors
class AuthorsController < ApplicationController
  before_action :set_entity, except: :index

  # get /authors
  def index
    @collection = EditorialMember.list_for_visitors
  end

  # get /authors/:slug
  def show
    @collection = Post.owned_by(@entity.user).page_for_visitors(current_page)
    respond_to do |format|
      format.html
      format.json { render('posts/index') }
    end
  end

  private

  def component_slug
    Biovision::Components::PostsComponent::SLUG
  end

  def set_entity
    user = User.find_by(slug: params[:slug].downcase, deleted: false)
    @entity = EditorialMember.visible.find_by(user: user)
    handle_http_404('Cannot find user') if @entity.nil?
  end
end
