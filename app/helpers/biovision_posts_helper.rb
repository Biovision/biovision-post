module BiovisionPostsHelper
  # @param [PostType] entity
  # @param [String] text
  def admin_post_type_link(entity, text = entity.name)
    link_to(text, admin_post_type_path(entity.id))
  end

  # @param [Post] entity
  # @param [String] text
  def admin_post_link(entity, text = entity.title)
    link_to(text, admin_post_path(entity.id))
  end

  # Post image preview for displaying in "administrative" lists
  #
  # @param [Post] entity
  def post_image_preview(entity)
    return '' if entity.image.blank?

    versions = "#{entity.image.preview_2x.url} 2x"
    image_tag(entity.image.preview.url, alt: entity.title, srcset: versions)
  end

  # @param [Post] entity
  def post_link(entity, text = entity.title)
    link_to(text, PostManager.handler(entity).post_path)
  end

  # Small post image for displaying in lists of posts and feeds
  #
  # @param [Post] entity
  def post_image_small(entity)
    return '' if entity.image.blank?

    versions = "#{entity.image.medium.url} 2x"
    image_tag(entity.image.small.url, alt: entity.title, srcset: versions)
  end

  # Medium post image for displaying on post page
  #
  # @param [Post] entity
  def post_image_medium(entity)
    return '' if entity.image.blank?

    versions = "#{entity.image.big.url} 2x"
    image_tag(entity.image.medium.url, alt: entity.title, srcset: versions)
  end
end
