# frozen_string_literal: true

# Handling uploaded inline post images
class Admin::PostIllustrationsController < AdminController
  before_action :set_entity, except: :index

  # get /admin/post_illustrations
  def index
    @collection = PostIllustration.page_for_administration(current_page)
  end

  # get /admin/post_illustrations/:id
  def show
  end

  private

  def set_entity
    @entity = PostIllustration.find_by(id: params[:id])
    handle_http_404('Cannot find post_illustration') if @entity.nil?
  end

  def restrict_access
    require_privilege_group :editors
  end
end
