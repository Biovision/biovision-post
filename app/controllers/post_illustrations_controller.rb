# frozen_string_literal: true

# Handling inline post image uploads
class PostIllustrationsController < ApplicationController
  before_action :restrict_access
  skip_before_action :verify_authenticity_token

  # post /post_illustrations
  def create
    render json: PostIllustration.ckeditor_upload!(ckeditor_parameters)
  end

  private

  def restrict_access
    require_privilege_group :editors
  end

  def ckeditor_parameters
    { image: params[:upload] }.merge(owner_for_entity(true))
  end
end
