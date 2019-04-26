# frozen_string_literal: true

# Editorial member
#
# Attributes:
#   about [Text], optional
#   created_at [DateTime]
#   user_id [User]
#   visible [Boolean]
#   priority [Integer]
#   updated_at [DateTime]
#   title [String], optional
#   lead [String], optional
class EditorialMember < ApplicationRecord
  include HasOwner
  include FlatPriority
  include Toggleable

  LEAD_LIMIT = 170
  TITLE_LIMIT = 150

  toggleable :visible

  belongs_to :user
  has_many :editorial_member_post_types, dependent: :delete_all
  has_many :post_types, through: :editorial_member_post_types

  after_initialize :set_next_priority
  before_validation :normalize_priority

  validates_length_of :lead, maximum: LEAD_LIMIT
  validates_length_of :title, maximum: TITLE_LIMIT
  validates_uniqueness_of :user_id

  scope :visible, -> { where(visible: true) }
  scope :with_post_type, ->(v) { joins(:editorial_member_post_types).where(editorial_member_post_types: { post_type: v }) }
  scope :list_for_visitors, -> { visible.ordered_by_priority }
  scope :list_for_administration, -> { ordered_by_priority }

  def self.entity_parameters
    %i[about lead title visible]
  end

  def self.creation_parameters
    entity_parameters + %i[user_id]
  end

  # @param [User] user
  def self.user?(user)
    user.is_a?(self) || owned_by(user).visible.exists?
  end

  def name
    user.profile_name
  end

  def profile_name
    user.profile_name
  end

  def screen_name
    user.screen_name
  end

  def slug
    user.slug
  end

  def post_count
    Post.owned_by(user).count
  end

  # @param [User] user
  def editable_by?(user)
    UserPrivilege.user_has_privilege?(user, :chief_editor)
  end

  # @param [PostType] post_type
  def post_type?(post_type)
    editorial_member_post_types.where(post_type: post_type).exists?
  end

  # @param [PostType] post_type
  def add_post_type(post_type)
    editorial_member_post_types.create(post_type: post_type)
  end

  # @param [PostType] post_type
  def remove_post_type(post_type)
    editorial_member_post_types.where(post_type: post_type).delete_all
  end
end
