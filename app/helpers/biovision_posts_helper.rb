# frozen_string_literal: true

# Helper methods for Posts component
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

  # @param [PostGroup] entity
  # @param [String] text
  # @param [Hash] options
  def admin_post_group_link(entity, text = entity.name, options = {})
    link_to(text, admin_post_group_path(id: entity.id), options)
  end

  # @param [PostImage] entity
  # @param [String] text
  def admin_post_image_link(entity, text = entity.name)
    link_to(text, admin_post_image_path(id: entity.id))
  end

  # @param [EditorialMember] entity
  # @param [String] text
  def admin_editorial_member_link(entity, text = entity.name)
    link_to(text, admin_editorial_member_path(id: entity.id))
  end

  # @param [Post] entity
  # @param [String] text
  # @param [Hash] options
  def my_post_link(entity, text = entity.title, options = {})
    link_to(text, my_post_path(id: entity.id), options)
  end

  # @param [User] entity
  # @param [String] text
  # @param [Hash] options
  def author_link(entity, text = entity&.profile_name, options = {})
    if EditorialMember.user?(entity)
      link_to(text, author_path(slug: entity.slug), options)
    elsif entity.is_a?(User)
      user_link(entity)
    end
  end

  # @param [Integer] post_type_id
  # @param [String] first_item
  def post_categories_for_select(post_type_id, first_item = t(:not_set))
    options = [[first_item, '']]
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

  def post_layouts_for_select
    options = PostLayout.ordered_by_name.map { |i| [i.name, i.id] }
    options + [[t(:not_set), '']]
  end

  # @param [Post] entity
  # @param [String] text
  # @param [Hash] options
  def post_link(entity, text = entity.title, options = {})
    link_to(text, PostManager.new(entity).post_path, options)
  end

  # @param [Post|PostCategory] entity
  def post_category_link(entity)
    handler = PostManager.new(entity)
    link_to(handler.category_name, handler.category_path)
  end

  # @param [PostGroup] entity
  # @param [String] text
  # @param [Hash] options
  def post_group_link(entity, text = entity.nav_text, options = {})
    link_to(text, post_group_path(id: entity.slug), options)
  end

  # @param [Post] entity
  # @param [Hash] options
  def post_author_link(entity, options = {})
    if entity.author_url.blank?
      raw("<span>#{entity.author_name}</span>")
    else
      link_options = {
        rel: 'external nofollow noopener noreferrer'
      }
      link_to(entity.author_name, entity.author_url, link_options.merge(options))
    end
  end

  # @param [String] tag_name
  # @param [Post] entity
  def tagged_posts_link(tag_name, entity = nil)
    if entity.nil?
      link_to(tag_name, tagged_posts_path(tag_name: tag_name), rel: 'tag')
    else
      handler = PostManager.new(entity)
      link_to(tag_name, handler.tagged_path(tag_name), rel: 'tag')
    end
  end

  # Post image preview for displaying in "administrative" lists
  #
  # @param [Post] entity
  def post_image_preview(entity)
    return '' if entity.image.blank?

    alt_text = entity.image_alt_text
    versions = "#{entity.image.preview_2x.url} 2x"
    image_tag(entity.image.preview.url, alt: alt_text, srcset: versions)
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

  # Large post image for displaying on post page
  #
  # @param [Post] entity
  # @param [Hash] add_options
  def post_image_large(entity, add_options = {})
    return '' if entity.image.blank?

    alt_text = entity.image_alt_text.to_s
    versions = "#{entity.image.hd.url} 2x"
    options  = { alt: alt_text, srcset: versions }.merge(add_options)
    image_tag(entity.image.big.url, options)
  end

  # Larger post image for displaying on post page
  #
  # @param [Post] entity
  # @param [Hash] add_options
  def post_image_hd(entity, add_options = {})
    return '' if entity.image.blank?

    alt_text = entity.image_alt_text.to_s
    options  = { alt: alt_text }.merge(add_options)
    image_tag(entity.image.hd.url, options)
  end
end
