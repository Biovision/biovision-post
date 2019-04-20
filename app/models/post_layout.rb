# frozen_string_literal: true

# Model for post layout
#
# Attributes:
#   name [String]
#   posts_count [Integer]
#   slug [String]
class PostLayout < ApplicationRecord
  include RequiredUniqueName
  include RequiredUniqueSlug

  has_many :posts, dependent: :nullify
end
