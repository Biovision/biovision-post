class PostManager
  # @param [Post] entity
  def initialize(entity)
    @entity = entity
    @body   = entity.body.to_s
  end

  # @param [Post] entity
  def self.handler(entity)
    handler_name  = "post_manager/#{entity.post_type.slug}_handler".classify
    handler_class = handler_name.safe_constantize || PostManager
    handler_class.new(entity)
  end

  def parsed_body
    @body.gsub(/<script/, '&lt;script')
  end

  def post_path
    "/posts/#{@entity.id}"
  end

  def edit_path
    "/posts/#{@entity.id}/edit"
  end
end
