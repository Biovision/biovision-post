# frozen_string_literal: true

ProfilesController.class_eval do
  # get /u/:slug/posts
  def posts
    @collection = Post.owned_by(@entity).page_for_visitors(current_page)
    render 'posts/index'
  end
end
