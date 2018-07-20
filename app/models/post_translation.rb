class PostTranslation < ApplicationRecord
  belongs_to :post
  belongs_to :language
  belongs_to :translated_post, class_name: Post.to_s

  validates_uniqueness_of :language_id, scope: [:post_id]
end
