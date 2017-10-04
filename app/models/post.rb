class Post < ApplicationRecord
  include HasOwner

  TITLE_LIMIT = 140
  SLUG_LIMIT  = 200
  SLUG_PATTERN = /\A[a-z0-9]+[-_.a-z0-9]*[a-z0-9]+\z/
  LEAD_LIMIT  = 350

  mount_uploader :image, PostImageUploader

  belongs_to :user
  belongs_to :region, optional: true
  belongs_to :post_type, counter_cache: true
  belongs_to :post_category, counter_cache: true, optional: true
  belongs_to :agent, optional: true

  after_initialize { self.uuid = SecureRandom.uuid if uuid.nil? }
  before_validation { self.slug = Canonizer.transliterate(title.to_s) if slug.blank? }
  before_validation { self.slug = slug.downcase }

  validates_presence_of :uuid, :title, :slug
  validates_length_of :title, maximum: TITLE_LIMIT
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_length_of :lead, maximum: LEAD_LIMIT
end
