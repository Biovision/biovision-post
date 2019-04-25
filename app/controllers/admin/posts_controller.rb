# frozen_string_literal: true

# Administrative part for posts management
class Admin::PostsController < AdminController
  include LockableEntity
  include ToggleableEntity

  before_action :set_entity, except: %i[index search]

  # get /admin/posts
  def index
    @filter = params[:filter] || {}
    @collection = Post.page_for_administration(current_page, @filter)
  end

  # get /admin/posts/:id
  def show
  end

  # get /admin/posts/:id/images
  def images
    @collection = @entity.post_images.list_for_administration
  end

  # get /admin/posts/search?q=
  def search
    @collection = params.key?(:q) ? search_posts(param_from_request(:q)) : []
  end

  private

  def set_entity
    @entity = Post.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post')
    end
  end

  def restrict_access
    require_privilege_group :editors
  end

  # @param [String] q
  def search_posts(q)
    if Post.respond_to?(:search)
      Post.search(q).records.first(50)
    else
      Post.where('title ilike ?', "%#{q}%").list_for_administration.first(50)
    end
  end
end
