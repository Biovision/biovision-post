class PostManager::ArticleHandler < PostManager
  def post_path
    "/articles/#{@entity.id}-#{@entity.slug}"
  end

  # @param [PostCategory] category
  def category_path(category)
    "/articles/#{category.long_slug}"
  end
end
