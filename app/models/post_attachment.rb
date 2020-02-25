# frozen_string_literal: true

# Model for post attachment
#
# Attributes
#   created_at [DateTime]
#   file [SimpleFileUploader]
#   name [String]
#   post_id [Post]
#   updated_at [DateTime]
#   uuid [UUID]
class PostAttachment < ApplicationRecord
  include Checkable
  include HasUuid

  NAME_LIMIT = 120

  mount_uploader :file, SimpleFileUploader

  belongs_to :post

  validates_length_of :name, maximum: NAME_LIMIT
  validates_presence_of :file

  scope :ordered_for_list, -> { order('name asc, file asc') }

  def self.entity_parameters
    %i[file name]
  end

  def name!
    return '' if file.blank?

    name.blank? ? CGI.unescape(File.basename(file.path)) : name
  end

  def size
    return 0 if file.blank?

    File.size(file.path)
  end

  # @param [User] user
  # @deprecated use component handler
  def editable_by?(user)
    Biovision::Components::PostsComponent[user]&.editable?(post)
  end
end
