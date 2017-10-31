class Post < ApplicationRecord
  include HasOwner
  include CommentableItem if 'CommentableItem'.safe_constantize
  include VotableItem if 'VotableItem'.safe_constantize

  TITLE_LIMIT  = 140
  SLUG_LIMIT   = 200
  SLUG_PATTERN = /\A[a-z0-9]+[-_.a-z0-9]*[a-z0-9]+\z/
  LEAD_LIMIT   = 350
  BODY_LIMIT   = 50000
  META_LIMIT   = 100
  PER_PAGE     = 10

  mount_uploader :image, PostImageUploader

  belongs_to :user
  belongs_to :region, optional: true
  belongs_to :post_type, counter_cache: true
  belongs_to :post_category, counter_cache: true, optional: true
  belongs_to :agent, optional: true

  after_initialize { self.uuid = SecureRandom.uuid if uuid.nil? }
  before_validation { self.slug = Canonizer.transliterate(title.to_s) if slug.blank? }
  before_validation { self.slug = slug.downcase }
  before_validation { self.publication_time = Time.now if publication_time.nil? }
  before_save { self.parsed_body = PostManager.handler(self).parsed_body }

  validates_presence_of :uuid, :title, :slug, :body
  validates_length_of :title, maximum: TITLE_LIMIT
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_length_of :lead, maximum: LEAD_LIMIT
  validates_length_of :body, maximum: BODY_LIMIT
  validates_length_of :image_name, maximum: META_LIMIT
  validates_length_of :image_author_name, maximum: META_LIMIT
  validates_length_of :image_author_link, maximum: META_LIMIT
  validates_length_of :source_link, maximum: META_LIMIT
  validates_length_of :source_name, maximum: META_LIMIT
  validates_format_of :slug, with: SLUG_PATTERN
  validate :category_consistency

  scope :recent, -> { order('publication_time desc') }
  scope :visible, -> { where(visible: true, deleted: false, approved: true) }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    recent.page(page).per(PER_PAGE)
  end

  # @param [Integer] page
  def self.page_for_visitors(page = 1)
    visible.recent.page(page).per(PER_PAGE)
  end

  def self.entity_parameters
    main_data  = %i(post_category_id title slug lead body visible region_id)
    image_data = %i(image image_name image_author_name image_author_link)
    meta_data  = %i(source_name source_link publication_time)
    flags_data = %i(show_owner allow_comments)

    main_data + image_data + meta_data + flags_data
  end

  def self.creation_parameters
    entity_parameters + %i(post_type_id)
  end

  private

  def category_consistency
    return if post_category.nil?
    if post_category.post_type != post_type
      errors.add(:post_category, I18n.t('activerecord.errors.messages.mismatches_post_type'))
    end
  end
end
