class PostLink < ApplicationRecord
  include PostChildWithPriority

  belongs_to :other_post, class_name: Post.to_s

  validates_uniqueness_of :other_post_id, scope: [:post_id]

  def self.entity_parameters
    %i(priority)
  end

  def self.creation_parameters
    %i(post_id other_post_id)
  end
end
