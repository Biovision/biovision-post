module PostChildWithPriority
  extend ActiveSupport::Concern

  included do
    belongs_to :post

    after_initialize :set_next_priority
    before_validation :normalize_priority

    scope :siblings, ->(entity) { where(post_id: entity.post_id) }
    scope :ordered_by_priority, -> { order 'priority asc, id desc' }

    def self.priority_range
      (1..32767)
    end

    # @param [User] user
    # @deprecated use component handler
    def editable_by?(user)
      Biovision::Components::BaseComponent.handler('posts', user).editable?(post)
    end

    # @param [Integer] delta
    def change_priority(delta)
      new_priority = priority + delta
      criteria     = { post_id: post_id, priority: new_priority }
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
      range = self.class.priority_range
      self.priority = range.first if priority < range.first
      self.priority = range.last if priority > range.last
    end
  end
end