# frozen_string_literal: true

# Model for link between editorial member and available post type
#
# Attributes:
#   created_at [DateTime]
#   editorial_member_id [EditorialMember]
#   post_type_id [PostType]
#   updated_at [DateTime]
class EditorialMemberPostType < ApplicationRecord
  belongs_to :editorial_member
  belongs_to :post_type

  validates_uniqueness_of :post_type_id, scope: :editorial_member_id
end
