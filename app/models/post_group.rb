# frozen_string_literal: true

# Model for post category group
#
# Attributes:
#   created_at [DateTime]
#   name [String]
#   nav_text [String]
#   priority [Integer]
#   slug [String]
#   updated_at [DateTime]
#   visible [Boolean]
class PostGroup < ApplicationRecord
  include Checkable
  include FlatPriority
  include RequiredUniqueSlug
  include RequiredUniqueName
  include Toggleable

  NAME_LIMIT = 50
  NAV_TEXT_LIMIT = 50
  SLUG_LIMIT = 30
  SLUG_PATTERN = /\A[a-z][-_0-9a-z]+[a-z0-9]\z/.freeze
  SLUG_PATTERN_HTML = '^[a-zA-Z][-_0-9a-zA-Z]+[a-zA-Z0-9]$'

  toggleable :visible

  has_many :post_group_categories, dependent: :delete_all
  has_many :post_group_tags, dependent: :delete_all
  has_many :post_categories, through: :post_group_categories
  has_many :post_tags, through: :post_group_tags

  before_validation { self.slug = slug.to_s.downcase }

  scope :visible, -> { where(visible: true) }
  scope :list_for_visitors, -> { visible.ordered_by_priority }
  scope :list_for_administration, -> { ordered_by_priority }

  def self.entity_parameters
    %i[name nav_text priority slug visible]
  end

  # @param [String] slug
  def self.[](slug)
    find_by(slug: slug)
  end

  # @param [PostCategory] entity
  def add_category(entity)
    post_group_categories.create(post_category: entity)
  end

  # @param [PostCategory] entity
  def remove_category(entity)
    post_group_categories.where(post_category: entity).delete_all
  end

  # @param [PostCategory] entity
  def category?(entity)
    post_group_categories.where(post_category: entity).exists?
  end

  # @param [PostTag] entity
  def add_tag(entity)
    post_group_tags.create(post_tag: entity)
  end

  # @param [PostTag] entity
  def remove_tag(entity)
    post_group_tags.where(post_tag: entity).delete_all
  end

  # @param [PostTag] entity
  def tag?(entity)
    post_group_tags.where(post_tag: entity).exists?
  end

  # @param [Integer] page
  def posts_page(page = 1)
    post_ids = PostPostCategory.where(post_category_id: post_category_ids).pluck(:post_id)
    post_ids += PostPostTag.where(post_tag_id: post_tag_ids).pluck(:post_id)
    Post.list_for_visitors.where(id: post_ids.uniq).page(page)
  end
end
