class PostReference < ApplicationRecord
  include PostChildWithPriority

  META_LIMIT = 255

  validates_presence_of :title
  validates_length_of :authors, maximum: META_LIMIT
  validates_length_of :title, maximum: META_LIMIT
  validates_length_of :url, maximum: META_LIMIT
  validates_length_of :publishing_info, maximum: META_LIMIT

  def self.entity_parameters
    %i(priority authors title url publishing_info)
  end

  def self.creation_parameters
    entity_parameters + %i(post_id)
  end
end
