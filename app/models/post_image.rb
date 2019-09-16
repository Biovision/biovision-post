class PostImage < ApplicationRecord
  include Toggleable

  DESCRIPTION_LIMIT = 5000
  META_LIMIT        = 255
  PRIORITY_RANGE    = (1..32767)

  toggleable :visible

  mount_uploader :image, PostImageUploader

  belongs_to :post

  after_initialize { self.uuid = SecureRandom.uuid if uuid.nil? }
  after_initialize :set_next_priority
  before_validation :normalize_priority

  validates_presence_of :image
  validates_length_of :image_alt_text, maximum: META_LIMIT
  validates_length_of :caption, maximum: META_LIMIT
  validates_length_of :source_name, maximum: META_LIMIT
  validates_length_of :source_link, maximum: META_LIMIT
  validates_length_of :description, maximum: DESCRIPTION_LIMIT

  scope :recent, -> { order('id desc') }
  scope :ordered_by_priority, -> { order('priority asc, id asc') }
  scope :visible, -> { where(visible: true) }
  scope :list_for_visitors, -> { visible.ordered_by_priority }
  scope :list_for_administration, -> { ordered_by_priority }
  scope :siblings, -> (post_id) { where(post_id: post_id) }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    recent.page(page)
  end

  def self.entity_parameters
    %i[caption description image image_alt_text source_link source_name visible]
  end

  def self.creation_parameters
    entity_parameters + %i(post_id)
  end

  def name
    caption.blank? ? "#{post.title} — #{priority}" : caption
  end

  # @param [User] user
  def owned_by?(user)
    post.owned_by?(user)
  end

  # @param [User] user
  # @deprecated use component handler
  def editable_by?(user)
    Biovision::Components::BaseComponent.handler('posts', user).editable?(post)
  end

  def has_image_data?
    !caption.blank? || !source_name.blank? || !source_link.blank?
  end

  # @param [Integer] delta
  def change_priority(delta)
    new_priority = priority + delta
    criteria     = { priority: new_priority }
    adjacent     = self.class.siblings(post_id).find_by(criteria)
    if adjacent.is_a?(self.class) && (adjacent.id != id)
      adjacent.update!(priority: priority)
    end
    self.update(priority: new_priority)

    self.class.siblings(post_id).map { |e| [e.id, e.priority] }.to_h
  end

  private

  def set_next_priority
    if id.nil? && priority == 1
      self.priority = self.class.siblings(post_id).maximum(:priority).to_i + 1
    end
  end

  def normalize_priority
    self.priority = PRIORITY_RANGE.first if priority < PRIORITY_RANGE.first
    self.priority = PRIORITY_RANGE.last if priority > PRIORITY_RANGE.last
  end
end
