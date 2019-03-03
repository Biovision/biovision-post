# frozen_string_literal: true

# Featured post
class FeaturedPost < ApplicationRecord
  include NestedPriority

  PRIORITY_RANGE = (1..100).freeze

  belongs_to :language
  belongs_to :post

  validates_uniqueness_of :post_id, scope: :language_id

  scope :ordered_by_priority, -> { order 'priority asc, id desc' }
  scope :list_for_language, ->(language) { where(language: language).ordered_by_priority }

  def self.siblings(entity)
    where(language_id: entity.language_id)
  end
end
