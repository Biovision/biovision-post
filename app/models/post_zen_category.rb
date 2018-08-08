class PostZenCategory < ApplicationRecord
  belongs_to :post
  belongs_to :zen_category, counter_cache: :posts_count

  validates_uniqueness_of :zen_category_id, scope: [:post_id]
end
