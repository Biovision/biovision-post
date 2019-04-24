# frozen_string_literal: true

# Post tag
class PostTag < ApplicationRecord
  NAME_LIMIT = 255

  belongs_to :post_type
  has_many :post_post_tags, dependent: :delete_all
  has_many :posts, through: :post_post_tags

  before_validation { self.name = name.to_s.squish[0..NAME_LIMIT] }
  before_validation { self.slug = Canonizer.canonize(name) unless name.blank? }

  validates_presence_of :name, :slug
  validates_uniqueness_of :slug, scope: :post_type_id
  validates_length_of :name, maximum: NAME_LIMIT

  scope :ordered_by_slug, -> { order('slug asc') }
  scope :popular, -> { order('posts_count desc, slug asc') }
  scope :with_posts, -> { where('posts_count > 0') }
  scope :with_name_like, ->(v) { where('name ilike ?', "%#{v}%") unless v.blank? }
  scope :list_for_administration, -> { ordered_by_slug }
  scope :list_for_visitors, -> { with_posts.ordered_by_slug }
  scope :ids_for_name, ->(name) { where(slug: Canonizer.canonize(name)).pluck(:id) }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    list_for_administration.page(page)
  end

  def self.entity_parameters
    %i[name]
  end

  def self.creation_parameters
    entity_parameters + %i[post_type_id]
  end

  # @param [Integer] post_type_id
  # @param [String] name
  def self.match_by_name(post_type_id, name)
    find_by(post_type_id: post_type_id, slug: Canonizer.canonize(name))
  end

  # @param [Integer] post_type_id
  # @param [String] name
  def self.match_or_create_by_name(post_type_id, name)
    entity = find_by(post_type_id: post_type_id, slug: Canonizer.canonize(name))
    entity || create(post_type_id: post_type_id, name: name)
  end

  def name_for_url
    Canonizer.urlize name
  end

  # @param [Post] post
  def post?(post)
    post_post_tags.exist?(post: post)
  end

  # @param [Post] post
  def add_post(post)
    post_post_tags.create(post: post) unless post.nil?
  end

  # @param [Post] post
  def remove_post(post)
    post_post_tags.where(post: post).delete_all
  end
end
