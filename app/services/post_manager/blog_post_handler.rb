class PostManager::BlogPostHandler < PostManager
  def post_path
    "/blog_posts/#{@entity.id}-#{@entity.slug}"
  end
end
