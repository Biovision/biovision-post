# frozen_string_literal: true

# Inline post illustration
#
# Attributes:
#   agent_id [Agent], optional
#   created_at [DateTime]
#   image [SimpleImageUploader]
#   ip [Inet], optional
#   updated_at [DateTime]
#   user_id [User], optional
class PostIllustration < ApplicationRecord
  include HasOwner

  mount_uploader :image, SimpleImageUploader

  belongs_to :agent, optional: true
  belongs_to :user, optional: true

  validates_presence_of :image

  # @param [Hash] parameters
  def self.ckeditor_upload!(parameters)
    entity = new(parameters)
    if entity.save
      entity.ckeditor_data
    else
      {
        uploaded: 0,
        error: 'Could not upload image'
      }
    end
  end

  # Response data for CKEditor upload
  def ckeditor_data
    {
      uploaded: 1,
      fileName: File.basename(image.path),
      url: image.hd_url
    }
  end
end
