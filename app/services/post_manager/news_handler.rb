class PostManager::NewsHandler < PostManager
  def post_path
    "#{@prefix}/news/#{@entity.id}-#{@entity.slug}"
  end

  # @param [PostCategory] category
  def category_path(category)
    "#{@prefix}/news/#{category.long_slug}"
  end

  def empty_category_path
    "#{@prefix}/news"
  end
end
