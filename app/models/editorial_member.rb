class EditorialMember < ApplicationRecord
  include HasOwner
  include Toggleable

  DESCRIPTION_LIMIT = 5000
  LEAD_LIMIT        = 170
  PRIORITY_RANGE    = (1..32767)
  TITLE_LIMIT       = 150

  toggleable :visible

  belongs_to :user

  after_initialize :set_next_priority
  before_validation :normalize_priority

  validates_length_of :description, maximum: DESCRIPTION_LIMIT
  validates_length_of :lead, maximum: LEAD_LIMIT
  validates_length_of :title, maximum: TITLE_LIMIT

  scope :ordered_by_priority, -> { order('priority asc') }
  scope :visible, -> { where(visible: true) }
  scope :list_for_visitors, -> { visible.ordered_by_priority }
  scope :list_for_administration, -> { ordered_by_priority }

  def self.entity_parameters
    %i[description lead title visible]
  end

  def self.creation_parameters
    entity_parameters + %i[user_id]
  end

  # @param [Integer] delta
  def change_priority(delta)
    new_priority = priority + delta
    criteria     = { priority: new_priority }
    adjacent     = self.class.find_by(criteria)
    if adjacent.is_a?(self.class) && (adjacent.id != id)
      adjacent.update!(priority: priority)
    end
    self.update(priority: new_priority)

    self.class.ordered_by_priority.map { |e| [e.id, e.priority] }.to_h
  end

  private

  def set_next_priority
    if id.nil? && priority == 1
      self.priority = self.class.maximum(:priority).to_i + 1
    end
  end

  def normalize_priority
    self.priority = PRIORITY_RANGE.first if priority < PRIORITY_RANGE.first
    self.priority = PRIORITY_RANGE.last if priority > PRIORITY_RANGE.last
  end
end
