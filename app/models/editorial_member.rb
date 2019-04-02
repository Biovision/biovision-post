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

  after_initialize :set_next_priority
  before_validation :normalize_priority

  validates_length_of :lead, maximum: LEAD_LIMIT
  validates_length_of :title, maximum: TITLE_LIMIT

  scope :visible, -> { where(visible: true) }
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

  def post_count
    Post.owned_by(user).count
  end
end
