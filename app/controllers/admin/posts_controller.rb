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

  def component_slug
    Biovision::Components::PostsComponent::SLUG
  end

  def restrict_access
    error = 'Managing posts is not allowed'
    handle_http_401(error) unless component_handler.allow?
  end

  def set_entity
    @entity = Post.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find post')
    end
  end

  # @param [String] q
  def search_posts(q)
    if Post.respond_to?(:search)
      Post.search(q).records.page(current_page)
    else
      Post.where('title ilike ?', "%#{q}%").page_for_administration(current_page)
    end
  end
end
