class PostNote < ApplicationRecord
  include PostChildWithPriority

  TEXT_LIMIT = 1000

  validates_presence_of :text
  validates_length_of :text, maximum: TEXT_LIMIT

  def self.entity_parameters
    %i(priority text)
  end

  def self.creation_parameters
    entity_parameters + %i(post_id)
  end
end
