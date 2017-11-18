class PostManager::BlogPostHandler < PostManager
  def post_path
    "/blog_posts/#{@entity.id}-#{@entity.slug}"
  end

  # @param [PostCategory] category
  def category_path(category)
    "/blog_posts/#{category.long_slug}"
  end
end
