module BiovisionPostsHelper
  # @param [PostType] entity
  # @param [String] text
  def admin_post_type_link(entity, text = entity.name)
    link_to(text, admin_post_type_path(id: entity.id))
  end

  # @param [PostCategory] entity
  # @param [String] text
  def admin_post_category_link(entity, text = entity.name)
    link_to(text, admin_post_category_path(id: entity.id))
  end

  # @param [Post] entity
  # @param [String] text
  def admin_post_link(entity, text = entity.title)
    link_to(text, admin_post_path(id: entity.id))
  end

  # @param [PostTag] entity
  # @param [String] text
  def admin_post_tag_link(entity, text = entity.name)
    link_to(text, admin_post_tag_path(id: entity.id))
  end

  # @param [Integer] post_type_id
  def post_categories_for_select(post_type_id)
    options = [[t(:not_set), '']]
    PostCategory.for_tree(post_type_id).each do |category|
      options << [category.name, category.id]
      if category.child_categories.any?
        PostCategory.for_tree(post_type_id, category.id).each do |subcategory|
          options << ["-#{subcategory.name}", subcategory.id]
          if subcategory.child_categories.any?
            PostCategory.for_tree(post_type_id, subcategory.id).each do |deep_category|
              options << ["--#{deep_category.name}", deep_category.id]
            end
          end
        end
      end
    end
    options
  end

  # @param [Post] entity
  # @param [String] text
  # @param [Hash] options
  def post_link(entity, text = entity.title, options = {})
    link_to(text, PostManager.handler(entity, locale).post_path, options)
  end

  # @param [Post] entity
  # @param [Hash] options
  def post_author_link(entity, options = {})
    if entity.author_url.blank?
      entity.author_name
    else
      link_options = {
        rel: 'external nofollow noopener noreferrer'
      }
      link_to(entity.author_name, entity.author_url, link_options.merge(options))
    end
  end

  # Post image preview for displaying in "administrative" lists
  #
  # @param [Post] entity
  def post_image_preview(entity)
    return '' if entity.image.blank?

    versions = "#{entity.image.preview_2x.url} 2x"
    image_tag(entity.image.preview.url, alt: entity.title, srcset: versions)
  end

  # Small post image for displaying in lists of posts and feeds
  #
  # @param [Post] entity
  # @param [Hash] add_options
  def post_image_small(entity, add_options = {})
    return '' if entity.image.blank?

    alt_text = entity.image_alt_text.to_s
    versions = "#{entity.image.medium.url} 2x"
    options  = { alt: alt_text, srcset: versions }.merge(add_options)
    image_tag(entity.image.small.url, options)
  end

  # Medium post image for displaying on post page
  #
  # @param [Post] entity
  # @param [Hash] add_options
  def post_image_medium(entity, add_options = {})
    return '' if entity.image.blank?

    alt_text = entity.image_alt_text.to_s
    versions = "#{entity.image.big.url} 2x"
    options  = { alt: alt_text, srcset: versions }.merge(add_options)
    image_tag(entity.image.medium.url, options)
  end
end
