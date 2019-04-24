# frozen_string_literal: true

# Post category
#
# Attributes:
#   children_cache [Array<Integer>]
#   created_at [DateTime]
#   meta_description [String], optional
#   name [String]
#   nav_text [String], optional
#   parent_id [PostCategory], optional
#   parents_cache [String]
#   post_type_id [PostType]
#   priority [Integer]
#   slug [String]
#   updated_at [DateTime]
#   visible [Boolean]
class PostCategory < ApplicationRecord
  include Checkable
  include NestedPriority
  include Toggleable

  META_LIMIT = 250
  NAME_LIMIT = 100
  SLUG_LIMIT = 100
  SLUG_PATTERN = /\A[a-z][-_0-9a-z]*[0-9a-z]\z/i.freeze

  toggleable :visible

  belongs_to :post_type
  belongs_to :parent, class_name: PostCategory.to_s, optional: true, touch: true
  has_many :child_categories, class_name: PostCategory.to_s, foreign_key: :parent_id, dependent: :destroy
  has_many :post_post_categories, dependent: :delete_all
  has_many :posts, through: :post_post_categories

  before_validation { self.slug = Canonizer.transliterate(name.to_s) if slug.blank? }
  before_validation { self.slug = slug.to_s.downcase }
  before_validation :generate_long_slug
  before_save { children_cache.uniq! }
  after_create :cache_parents!
  after_save { parent&.cache_children! }

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, scope: %i[post_type_id parent_id]
  validates_uniqueness_of :slug, scope: :post_type_id
  validates_length_of :meta_description, maximum: META_LIMIT
  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :nav_text, maximum: NAME_LIMIT
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_format_of :slug, with: SLUG_PATTERN
  validate :parent_matches_type
  validate :parent_is_not_too_deep

  scope :visible, -> { where(visible: true, deleted: false) }
  scope :for_tree, ->(post_type_id, parent_id = nil) { where(post_type_id: post_type_id, parent_id: parent_id).ordered_by_priority }
  scope :ids_for_slug, ->(slug) { where(long_slug: slug.to_s.downcase).pluck(:id) }

  def self.entity_parameters
    %i[meta_description name nav_text slug priority visible]
  end

  def self.creation_parameters
    entity_parameters + %i[parent_id post_type_id]
  end

  # @param [PostCategory] entity
  def self.siblings(entity)
    where(post_type_id: entity.post_type_id, parent_id: entity.parent_id)
  end

  # @param [Integer] post_type_id
  def self.list_for_tree(post_type_id)
    buffer = {}
    where(post_type_id: post_type_id).ordered_by_priority.each do |item|
      buffer[item.id] = {
        parent_id: item.parent_id,
        item: item
      }
    end
    buffer
  end

  def full_title
    (parents.pluck(:name) + [name]).join ' / '
  end

  def depth
    parent_ids.count
  end

  def parent_ids
    parents_cache.split(',').compact
  end

  # @return [Array<Integer>]
  def branch_ids
    parents_cache.split(',').map(&:to_i).reject { |i| i < 1 }.uniq + [id]
  end

  # @return [Array<Integer>]
  def subbranch_ids
    [id] + children_cache
  end

  def parents
    return [] if parents_cache.blank?

    PostCategory.where(id: parent_ids).order('id asc')
  end

  def cache_parents!
    return if parent.nil?

    self.parents_cache = "#{parent.parents_cache},#{parent_id}".gsub(/\A,/, '')
    save!
  end

  def cache_children!
    child_categories.order('id asc').each do |child|
      self.children_cache += [child.id] + child.children_cache
    end
    save!
  end

  def can_be_deleted?
    !locked? && child_categories.count < 1
  end

  # @param [Post] post
  def post?(post)
    post_post_categories.where(post: post).exists?
  end

  # @param [Post] post
  def add_post(post)
    post_post_categories.create(post: post)
  end

  # @param [Post] post
  def remove_post(post)
    post_post_categories.where(post: post).delete_all
  end

  def text_for_link
    nav_text.blank? ? name : nav_text
  end

  private

  def generate_long_slug
    self.long_slug = parent.nil? ? slug : "#{parent.long_slug}_#{slug}"
  end

  def parent_matches_type
    return if parent.nil? || parent.post_type == post_type

    error = I18n.t('activerecord.errors.messages.mismatches_post_type')
    errors.add(:parent_id, error)
  end

  def parent_is_not_too_deep
    return if parent.nil? || parent.depth < post_type.category_depth

    error = I18n.t('activerecord.errors.models.post_category.attributes.parent_id.is_too_deep')
    errors.add(:parent_id, error)
  end
end
