class PostManager::ArticleHandler < PostManager
  def post_path
    "#{@prefix}/articles/#{@entity.id}-#{@entity.slug}"
  end

  # @param [String] tag_name
  def tagged_path(tag_name)
    "#{@prefix}/articles/tagged/#{URI.encode(tag_name)}"
  end

  # @param [PostCategory] category
  def category_path(category)
    "#{@prefix}/articles/#{category.long_slug}"
  end

  def empty_category_path
    "#{@prefix}/articles"
  end
end
