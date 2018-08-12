class Post < ApplicationRecord
  include HasOwner
  include CommentableItem if Gem.loaded_specs.key?('biovision-comment')
  include VotableItem if Gem.loaded_specs.key?('biovision-vote')
  include Toggleable

  if Gem.loaded_specs.key?('elasticsearch-model')
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    index_name Rails.configuration.post_index_name
  end

  ALT_LIMIT         = 255
  BODY_LIMIT        = 50000
  IMAGE_NAME_LIMIT  = 500
  LEAD_LIMIT        = 5000
  META_LIMIT        = 250
  SLUG_LIMIT        = 200
  SLUG_PATTERN      = /\A[a-z0-9]+[-_.a-z0-9]*[a-z0-9]+\z/
  SLUG_PATTERN_HTML = '^[a-zA-Z0-9]+[-_.a-zA-Z0-9]*[a-zA-Z0-9]+$'
  TIME_RANGE        = (0..1440)
  TITLE_LIMIT       = 255

  URL_PATTERN = /https?:\/\/([^\/]+)\/?.*/
  PER_PAGE    = 12

  toggleable :visible, :show_owner

  mount_uploader :image, PostImageUploader

  belongs_to :user
  belongs_to :region, optional: true if Gem.loaded_specs.key?('biovision-regions')
  belongs_to :post_type, counter_cache: true
  belongs_to :post_category, counter_cache: true, optional: true
  belongs_to :language, optional: true
  belongs_to :agent, optional: true
  has_many :post_references, dependent: :delete_all
  has_many :post_notes, dependent: :delete_all
  has_many :post_links, dependent: :delete_all
  has_many :post_post_tags, dependent: :destroy
  has_many :post_tags, through: :post_post_tags
  has_many :post_images, dependent: :destroy
  has_many :post_translations, dependent: :delete_all
  has_many :post_zen_categories, dependent: :destroy
  has_many :zen_categories, through: :post_zen_categories

  after_initialize { self.uuid = SecureRandom.uuid if uuid.nil? }
  after_initialize { self.publication_time = Time.now if publication_time.nil? }
  before_validation { self.slug = Canonizer.transliterate(title.to_s) if slug.blank? }
  before_validation { self.slug = slug.downcase }
  before_validation :prepare_source_names
  before_save { self.parsed_body = PostManager.handler(self).parsed_body }

  validates_presence_of :uuid, :title, :slug, :body
  validates_length_of :title, maximum: TITLE_LIMIT
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_length_of :lead, maximum: LEAD_LIMIT
  validates_length_of :body, maximum: BODY_LIMIT
  validates_length_of :image_name, maximum: IMAGE_NAME_LIMIT
  validates_length_of :image_alt_text, maximum: ALT_LIMIT
  validates_length_of :image_author_name, maximum: META_LIMIT
  validates_length_of :image_author_link, maximum: META_LIMIT
  validates_length_of :source_link, maximum: META_LIMIT
  validates_length_of :source_name, maximum: META_LIMIT
  validates_length_of :original_title, maximum: META_LIMIT
  validates_length_of :meta_title, maximum: TITLE_LIMIT
  validates_length_of :meta_description, maximum: META_LIMIT
  validates_length_of :meta_keywords, maximum: META_LIMIT
  validates_length_of :author_name, maximum: META_LIMIT
  validates_length_of :author_title, maximum: META_LIMIT
  validates_length_of :author_url, maximum: META_LIMIT
  validates_length_of :translator_name, maximum: META_LIMIT
  validates_format_of :slug, with: SLUG_PATTERN
  validates_numericality_of :time_required, in: TIME_RANGE, allow_nil: true
  validate :category_consistency

  scope :recent, -> { order('publication_time desc') }
  scope :popular, -> { order('rating desc') }
  scope :visible, -> { where(visible: true, deleted: false, approved: true) }
  scope :published, -> { where('publication_time <= current_timestamp') }
  scope :for_language, -> (language) { where(language: language) }
  scope :list_for_visitors, -> { visible.published.recent }
  scope :list_for_administration, -> { order('id desc') }
  scope :list_for_owner, -> (user) { owned_by(user).recent }
  scope :tagged, -> (tag) { joins(:post_post_tags).where(post_post_tags: { post_tag_id: PostTag.ids_for_name(tag) }).distinct unless tag.blank? }
  scope :in_category, -> (slug) { where(post_category_id: PostCategory.ids_for_slug(slug)).distinct unless slug.blank? }
  scope :in_category_branch, -> (category) { where(post_category_id: category.subbranch_ids) }
  scope :authors, -> { User.where(id: Post.author_ids).order('screen_name asc') }
  scope :of_type, -> (slug) { where(post_type: PostType.find_by(slug: slug)) }
  scope :posted_after, -> (time) { where('publication_time >= ?', time) }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    list_for_administration.page(page).per(PER_PAGE)
  end

  # @param [Integer] page
  def self.page_for_visitors(page = 1)
    list_for_visitors.page(page).per(PER_PAGE)
  end

  # @param [User] user
  # @param [Integer] page
  def self.page_for_owner(user, page = 1)
    list_for_owner(user).page(page)
  end

  def self.entity_parameters
    main_data   = %i[body language_id lead original_title post_category_id publication_time region_id slug title]
    image_data  = %i[image image_alt_text image_author_link image_author_name image_name]
    meta_data   = %i[rating source_name source_link meta_title meta_description meta_keywords time_required]
    flags_data  = %i[allow_comments allow_votes explicit show_owner visible translation]
    author_data = %i[author_name author_title author_url translator_name]

    main_data + image_data + meta_data + author_data + flags_data
  end

  def self.creation_parameters
    entity_parameters + %i(post_type_id)
  end

  def self.author_ids
    visible.pluck(:user_id).uniq
  end

  # Lead or the first passage of body
  def lead!
    if lead.blank?
      (parsed_body.blank? ? body : parsed_body).match(/<p>(.+?)<\/p>/)[1].to_s[0..499]
    else
      lead
    end
  end

  # Get the most suitable author name for post
  def author!(default_name = '')
    return default_name unless show_owner
    if author_name.blank?
      user.profile_name
    else
      author_name
    end
  end

  # List of linked posts for visitors
  def linked_posts
    result = []
    post_links.ordered_by_priority.each do |link|
      result << link.other_post if link.other_post.visible_to_visitors?
    end
    result
  end

  def locale
    language&.code.to_s
  end

  def translations
    post_translations.each.map { |l| [l.language.code, l.translated_post] }.to_h
  end

  def visible_to_visitors?
    visible? && !deleted? && approved?
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

  def tags_string
    post_tags.ordered_by_slug.map(&:name).join(', ')
  end

  # @param [String] input
  def tags_string=(input)
    list = []
    input.split(/,\s*/).reject { |tag_name| tag_name.blank? }.each do |tag_name|
      list << PostTag.match_or_create_by_name(post_type_id, tag_name.squish)
    end
    self.post_tags = list.uniq
    cache_tags!
  end

  def cache_tags!
    update! tags_cache: post_tags.order('slug asc').map(&:name)
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
      begin
        self.image_author_name = URI.parse(image_author_link).host
      rescue URI::InvalidURIError
        self.image_author_name = URL_PATTERN.match(image_author_link)[1]
      end
    end
    if source_name.blank? && !source_link.blank?
      begin
        self.source_name = URI.parse(source_link).host
      rescue URI::InvalidURIError
        self.source_name = URL_PATTERN.match(source_link)[1]
      end
    end
  end
end
