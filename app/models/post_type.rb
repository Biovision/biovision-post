# frozen_string_literal: true

# Post type
#
# Attributes:
#   active [Boolean]
#   category_depth [Integer]
#   created_at [DateTime]
#   default_category_name [String], optional
#   name [String]
#   slug [String]
#   updated_at [DateTime]
class PostType < ApplicationRecord
  include RequiredUniqueName
  include RequiredUniqueSlug

  NAME_LIMIT = 50
  SLUG_LIMIT = 50
  SLUG_PATTERN = /\A[a-z]+[0-9a-z_]*[0-9a-z]\z/.freeze
  DEPTH_RANGE = (0..10).freeze

  has_many :post_categories, dependent: :destroy
  has_many :posts
  has_many :post_tags, dependent: :delete_all
  has_many :editorial_member_post_types, dependent: :delete_all
  has_many :editorial_members, through: :editorial_member_post_types

  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_format_of :slug, with: SLUG_PATTERN
  validates_inclusion_of :category_depth, in: DEPTH_RANGE

  scope :active, -> { where(active: true) }
  scope :list_for_administration, -> { active.ordered_by_name }

  def self.page_for_administration
    active.ordered_by_name
  end
end
