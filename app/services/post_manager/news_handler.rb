class PostManager::NewsHandler < PostManager
  def post_path
    "/news/#{@entity.id}-#{@entity.slug}"
  end

  # @param [PostCategory] category
  def category_path(category)
    "/news/#{category.long_slug}"
  end
end
