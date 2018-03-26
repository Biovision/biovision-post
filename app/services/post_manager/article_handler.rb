class PostManager::ArticleHandler < PostManager
  def post_path
    "#{@prefix}/articles/#{@entity.id}-#{@entity.slug}"
  end

  # @param [PostCategory] category
  def category_path(category)
    "#{@prefix}/articles/#{category.long_slug}"
  end
end
