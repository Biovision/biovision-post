class Post < ApplicationRecord
  include HasOwner
  include CommentableItem if 'CommentableItem'.safe_constantize
  include VotableItem if 'VotableItem'.safe_constantize

  TITLE_LIMIT  = 140
  SLUG_LIMIT   = 200
  SLUG_PATTERN = /\A[a-z0-9]+[-_.a-z0-9]*[a-z0-9]+\z/
  LEAD_LIMIT   = 350
  BODY_LIMIT   = 50000

  mount_uploader :image, PostImageUploader

  belongs_to :user
  belongs_to :region, optional: true
  belongs_to :post_type, counter_cache: true
  belongs_to :post_category, counter_cache: true, optional: true
  belongs_to :agent, optional: true

  after_initialize { self.uuid = SecureRandom.uuid if uuid.nil? }
  before_validation { self.slug = Canonizer.transliterate(title.to_s) if slug.blank? }
  before_validation { self.slug = slug.downcase }

  validates_presence_of :uuid, :title, :slug, :body
  validates_length_of :title, maximum: TITLE_LIMIT
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_length_of :lead, maximum: LEAD_LIMIT
  validates_length_of :body, maximum: BODY_LIMIT
  validates_format_of :slug, with: SLUG_PATTERN
  validate :category_consistency

  private

  def category_consistency
    return if post_category.nil?
    if post_category.post_type != post_type
      error = 'activerecord.errors.models.attributes.post.post_category.mismatches_post_type'
      errors.add(:post_category, I18n.t(error))
    end
  end
end
