# frozen_string_literal: true

# Featured post
#
# Attributes:
#   created_at [DateTime]
#   language_id [Language]
#   post_id [Post]
#   priority [Integer]
#   updated_at [DateTime]
class FeaturedPost < ApplicationRecord
  include NestedPriority

  belongs_to :language
  belongs_to :post

  validates_uniqueness_of :post_id, scope: :language_id

  scope :list_for_language, ->(v) { where(language: v).ordered_by_priority }

  # @param [FeaturedPost] entity
  def self.siblings(entity)
    where(language_id: entity.language_id)
  end
end
