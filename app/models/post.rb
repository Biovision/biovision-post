class Post < ApplicationRecord
  include HasOwner

  mount_uploader :image, PostImageUploader

  belongs_to :user
  belongs_to :region, optional: true
  belongs_to :post_type, counter_cache: true
  belongs_to :post_category, counter_cache: true, optional: true
  belongs_to :agent, optional: true

  after_initialize { self.uuid = SecureRandom.uuid if uuid.nil? }
  validates_presence_of :uuid
end
