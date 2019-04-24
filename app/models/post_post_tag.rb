# frozen_string_literal: true

# Link between post and post tag
#
# Attributes:
#   created_at [DateTime]
class PostPostTag < ApplicationRecord
  belongs_to :post
  belongs_to :post_tag, counter_cache: :posts_count

  validates_uniqueness_of :post_tag_id, scope: [:post_id]

  private

  def matching_post_type
    unless post.post_type_id == post_tag.post_type_id
      error = I18n.t('activerecord.errors.messages.mismatches_post_type')
      errors.add(:post_tag, error)
    end
  end
end
