# frozen_string_literal: true

# Link between post and post category
#
# Attributes:
#   created_at [DateTime]
#   post_category_id [PostCategory]
#   post_id [Post]
#   updated_at [DateTime]
class PostPostCategory < ApplicationRecord
  belongs_to :post
  belongs_to :post_category, counter_cache: :posts_count

  validates_uniqueness_of :post_category_id, scope: :post_id
  validate :category_consistency

  private

  def category_consistency
    return if post_category&.post_type == post&.post_type

    errors.add(:post_category_id, I18n.t('activerecord.errors.messages.mismatches_post_type'))
  end
end
