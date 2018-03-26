class PostManager
  # @param [Post] entity
  # @param [Symbol|String] locale
  def initialize(entity, locale = I18n.locale)
    @entity = entity
    @body   = entity.body.to_s
    @prefix = locale.nil? ? '' : "/#{locale}"
  end

  # @param [Post] entity
  # @param [Symbol|String] locale
  def self.handler(entity, locale = I18n.locale)
    handler_name  = "post_manager/#{entity.post_type.slug}_handler".classify
    handler_class = handler_name.safe_constantize || PostManager
    handler_class.new(entity, locale)
  end

  def parsed_body
    @body.gsub(/<script/, '&lt;script')
  end

  def post_path
    "#{@prefix}/posts/#{@entity.id}"
  end

  def edit_path
    "#{@prefix}/posts/#{@entity.id}/edit"
  end

  # @param [PostCategory] category
  def category_path(category)
    "#{@prefix}/posts/#{category.long_slug}"
  end
end
