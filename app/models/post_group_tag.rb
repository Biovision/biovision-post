# frozen_string_literal: true

# Model for post category in category group
#
# Attributes:
#   created_at [DateTime]
#   post_group_id [PostGroup]
#   post_tag_id [PostTag]
#   priority [Integer]
#   updated_at [DateTime]
class PostGroupTag < ApplicationRecord
  include NestedPriority

  belongs_to :post_group
  belongs_to :post_tag

  validates_uniqueness_of :post_tag_id, scope: :post_group_id

  scope :list_for_administration, -> { ordered_by_priority }

  # @param [PostGroupTag] entity
  def self.siblings(entity)
    where(post_group_id: entity.post_group_id)
  end

  # @param [String|PostGroup] slug
  def self.[](slug)
    post_group = slug.is_a?(PostGroup) ? slug : PostGroup[slug]

    where(post_group: post_group).ordered_by_priority.map(&:post_tag)
  end
end
