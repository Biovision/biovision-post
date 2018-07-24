class FeaturedPost < ApplicationRecord
  PRIORITY_RANGE = (1..100)

  belongs_to :language
  belongs_to :post

  after_initialize :set_next_priority
  before_validation :normalize_priority

  validates_uniqueness_of :post_id, scope: [:language_id]

  scope :siblings, ->(entity) { where(language_id: entity.language_id) }
  scope :ordered_by_priority, -> { order 'priority asc, id desc' }
  scope :list_for_language, ->(language) { where(language: language).ordered_by_priority }

  # @param [Integer] delta
  def change_priority(delta)
    new_priority = priority + delta
    criteria     = { language_id: language_id, priority: new_priority }
    adjacent     = self.class.find_by(criteria)
    if adjacent.is_a?(self.class) && (adjacent.id != id)
      adjacent.update!(priority: priority)
    end
    self.update(priority: new_priority)

    self.class.siblings(self).ordered_by_priority.map { |e| [e.id, e.priority] }.to_h
  end

  private

  def set_next_priority
    if id.nil? && priority == 1
      self.priority = self.class.siblings(self).maximum(:priority).to_i + 1
    end
  end

  def normalize_priority
    self.priority = PRIORITY_RANGE.first if priority < PRIORITY_RANGE.first
    self.priority = PRIORITY_RANGE.last if priority > PRIORITY_RANGE.last
  end
end
