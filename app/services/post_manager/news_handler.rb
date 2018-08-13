class PostManager::NewsHandler < PostManager
  def post_path
    "#{@prefix}/news/#{@entity.id}-#{@entity.slug}"
  end

  # @param [String] tag_name
  def tagged_path(tag_name)
    "#{@prefix}/news/tagged/#{URI.encode(tag_name)}"
  end

  # @param [PostCategory] category
  def category_path(category)
    "#{@prefix}/news/#{category.long_slug}"
  end

  def empty_category_path
    "#{@prefix}/news"
  end
end
