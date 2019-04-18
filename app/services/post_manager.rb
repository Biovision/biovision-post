# frozen_string_literal: true

# Manager for handling post-related cases
class PostManager
  # @param [Post|PostCategory] entity
  # @param [Symbol|String] locale
  def initialize(entity, locale = I18n.locale)
    @entity = entity
    @body = entity.body.to_s if @entity.is_a?(Post)
    @prefix = locale.nil? || locale == I18n.default_locale ? '' : "/#{locale}"
    @url_part = entity.post_type.url_part
  end

  # @param [User] user
  # @param [String|PostType] type
  def self.editor?(user, type)
    return true if UserPrivilege.user_has_privilege?(user, :chief_editor)

    type = PostType.find_by(slug: type) unless type.is_a?(PostType)

    EditorialMember.find_by(user: user)&.post_type?(type)
  end

  # @param [Post] post
  def self.enclosures(post)
    post.parsed_body.scan(/<img[^>]+>/).map do |image|
      image.scan(/src="([^"]+)"/)[0][0]
    end
  end

  def parsed_body
    PostParser.new(@entity).parsed_body if @entity.is_a?(Post)
  end

  def post_path
    "#{@prefix}/#{@url_part}/#{@entity.id}-#{@entity.slug}" if @entity.is_a?(Post)
  end

  def edit_path
    "#{@prefix}/posts/#{@entity.id}/edit" if @entity.is_a?(Post)
  end

  # @param [String] tag_name
  def tagged_path(tag_name)
    "#{@prefix}/#{@url_part}/tagged/#{CGI.escape(tag_name)}"
  end

  def category_path
    postfix = ''
    suffix = @entity.is_a?(Post) ? @entity.post_category : @entity
    postfix += "/#{suffix.long_slug}" unless suffix.nil?

    empty_category_path + postfix
  end

  def category_name
    if @entity.is_a?(Post)
      if @entity.post_category.nil?
        @entity.post_type.default_category_name
      else
        @entity.post_category.text_for_link
      end
    else
      @entity.text_for_link
    end
  end

  def empty_category_path
    "#{@prefix}/#{@url_part}"
  end
end
