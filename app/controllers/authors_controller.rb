class AuthorsController < ApplicationController
  before_action :set_entity

  # get /authors
  def index
    @collection = Post.authors
  end

  # get /authors/:slug
  def show
    @collection = Post.owned_by(@entity).page_for_visitors(current_page)
    respond_to do |format|
      format.html
      format.json { render('posts/index') }
    end
  end

  private

  def set_entity
    @entity = User.find_by(slug: params[:slug].downcase, deleted: false)
    if @entity.nil?
      handle_http_404('Cannot find user')
    end
  end
end
