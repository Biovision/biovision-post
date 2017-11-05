class PostType < ApplicationRecord
  include RequiredUniqueName
  include RequiredUniqueSlug

  NAME_LIMIT = 50
  SLUG_LIMIT = 50
  SLUG_PATTERN = /\A[a-z]+[0-9a-z_]*[0-9a-z]\z/
  DEPTH_RANGE = (0..10)

  has_many :post_categories, dependent: :destroy
  has_many :posts

  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_format_of :slug, with: SLUG_PATTERN
  validates_inclusion_of :category_depth, in: DEPTH_RANGE

  def self.page_for_administration
    ordered_by_name
  end
end
