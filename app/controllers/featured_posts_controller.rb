class FeaturedPostsController < AdminController
  before_action :set_entity, only: :destroy

  # post /featured_posts
  def create
    @entity = FeaturedPost.new(creation_parameters)
    bump_priority
    if @entity.save
      render status: :created
    else
      render json: { errors: @entity.errors }, status: :bad_request
    end
  end

  # delete /featured_posts/:id
  def destroy
    @entity.destroy

    head :no_content
  end

  private

  def restrict_access
    require_privilege :chief_editor
  end

  def creation_parameters
    post = Post.find_by(id: params[:post_id])
    if post.nil?
      { post_id: nil, language_id: nil }
    else
      { post_id: post.id, language_id: post.language_id }
    end
  end

  def set_entity
    @entity = FeaturedPost.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find featured_post')
    end
  end

  def bump_priority
    @entity.priority = 1

    criteria = {
      language_id: @entity&.language_id,
      priority: 1
    }
    return unless FeaturedPost.exists?(criteria)

    query = %(update #{FeaturedPost.table_name}
      set priority = priority + 1
      where language_id = #{criteria[:language_id]};)

    FeaturedPost.connection.execute(query)
  end
end
