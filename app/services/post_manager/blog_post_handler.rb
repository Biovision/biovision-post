class PostManager::BlogPostHandler < PostManager
  def post_path
    "#{@prefix}/blog_posts/#{@entity.id}-#{@entity.slug}"
  end

  # @param [String] tag_name
  def tagged_path(tag_name)
    "#{@prefix}/blog_posts/tagged/#{URI.encode(tag_name)}"
  end

  # @param [PostCategory] category
  def category_path(category)
    "#{@prefix}/blog_posts/#{category.long_slug}"
  end

  def empty_category_path
    "#{@prefix}/blog_posts"
  end
end
