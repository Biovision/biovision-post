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

  def component_slug
    Biovision::Components::PostsComponent::SLUG
  end

  def restrict_access
    error = 'Managing post groups is not allowed'
    handle_http_401(error) unless component_handler.allow?
  end

  def ckeditor_parameters
    { image: params[:upload] }.merge(owner_for_entity(true))
  end
end
