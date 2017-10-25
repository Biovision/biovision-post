class PostType < ApplicationRecord
  include RequiredUniqueName
  include RequiredUniqueSlug

  NAME_LIMIT = 50
  SLUG_LIMIT = 50
  SLUG_PATTERN = /\A[a-z]+[0-9a-z_]*[0-9a-z]\z/
  DEPTH_RANGE = (0..10)

  belongs_to :parent, class_name: PostType.to_s, optional: true
  has_many :children, class_name: PostType.to_s, foreign_key: :parent_id
  has_many :post_categories, dependent: :destroy
  has_many :posts, through: :post_categories

  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_format_of :slug, with: SLUG_PATTERN
  validates_inclusion_of :category_depth, in: DEPTH_RANGE

  scope :for_tree, ->(parent_id = nil) { where(parent_id: parent_id).ordered_by_name }
end
