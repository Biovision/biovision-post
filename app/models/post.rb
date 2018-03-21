class Post < ApplicationRecord
  include HasOwner
  include CommentableItem if Gem.loaded_specs.key?('biovision-comment')
  include VotableItem if Gem.loaded_specs.key?('biovision-vote')
  include Toggleable

  TITLE_LIMIT       = 140
  SLUG_LIMIT        = 200
  SLUG_PATTERN      = /\A[a-z0-9]+[-_.a-z0-9]*[a-z0-9]+\z/
  SLUG_PATTERN_HTML = '^[a-zA-Z0-9]+[-_.a-zA-Z0-9]*[a-zA-Z0-9]+$'
  LEAD_LIMIT        = 350
  BODY_LIMIT        = 50000
  META_LIMIT        = 250
  ALT_LIMIT         = 200
  PER_PAGE          = 12

  toggleable :visible, :show_owner, :allow_comments

  mount_uploader :image, PostImageUploader

  belongs_to :user
  belongs_to :region, optional: true if Gem.loaded_specs.key?('biovision-regions')
  belongs_to :post_type, counter_cache: true
  belongs_to :post_category, counter_cache: true, optional: true
  belongs_to :language, optional: true
  belongs_to :agent, optional: true

  after_initialize { self.uuid = SecureRandom.uuid if uuid.nil? }
  before_validation { self.slug = Canonizer.transliterate(title.to_s) if slug.blank? }
  before_validation { self.slug = slug.downcase }
  before_validation :prepare_source_names
  before_save { self.parsed_body = PostManager.handler(self).parsed_body }

  validates_presence_of :uuid, :title, :slug, :body
  validates_length_of :title, maximum: TITLE_LIMIT
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_length_of :lead, maximum: LEAD_LIMIT
  validates_length_of :body, maximum: BODY_LIMIT
  validates_length_of :image_name, maximum: META_LIMIT
  validates_length_of :image_alt_text, maximum: ALT_LIMIT
  validates_length_of :image_author_name, maximum: META_LIMIT
  validates_length_of :image_author_link, maximum: META_LIMIT
  validates_length_of :source_link, maximum: META_LIMIT
  validates_length_of :source_name, maximum: META_LIMIT
  validates_length_of :meta_title, maximum: TITLE_LIMIT
  validates_length_of :meta_description, maximum: META_LIMIT
  validates_length_of :meta_keywords, maximum: META_LIMIT
  validates_length_of :author_name, maximum: META_LIMIT
  validates_length_of :author_title, maximum: META_LIMIT
  validates_length_of :author_url, maximum: META_LIMIT
  validates_format_of :slug, with: SLUG_PATTERN
  validate :category_consistency

  scope :recent, -> { order('id desc') }
  scope :visible, -> { where(visible: true, deleted: false, approved: true) }
  scope :list_for_visitors, -> { visible.recent }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    recent.page(page).per(PER_PAGE)
  end

  # @param [Integer] page
  def self.page_for_visitors(page = 1)
    list_for_visitors.page(page).per(PER_PAGE)
  end

  def self.entity_parameters
    main_data   = %i(post_category_id title slug lead body visible translation region_id)
    image_data  = %i(image image_alt_text image_name image_author_name image_author_link)
    meta_data   = %i(source_name source_link meta_title meta_description meta_keywords)
    flags_data  = %i(show_owner allow_comments)
    author_data = %i(author_name author_title author_url)

    main_data + image_data + meta_data + author_data + flags_data
  end

  def self.creation_parameters
    entity_parameters + %i(post_type_id)
  end

  # @param [User] user
  def editable_by?(user)
    owned_by?(user) || UserPrivilege.user_has_privilege?(user, :chief_editor)
  end

  def has_image_data?
    !image_name.blank? || !image_author_name.blank? || !image_author_link.blank?
  end

  def has_source_data?
    !source_name.blank? || !source_link.blank?
  end

  private

  def category_consistency
    return if post_category.nil?
    if post_category.post_type != post_type
      errors.add(:post_category, I18n.t('activerecord.errors.messages.mismatches_post_type'))
    end
  end

  def prepare_source_names
    if image_author_name.blank? && !image_author_link.blank?
      self.image_author_name = URI.parse(image_author_name).host
    end
    if source_name.blank? && !source_link.blank?
      self.source_name = URI.parse(source_link).host
    end
  end
end
