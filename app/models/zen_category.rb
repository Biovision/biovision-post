class ZenCategory < ApplicationRecord
  include RequiredUniqueName

  has_many :post_zen_categories, dependent: :delete_all
  has_many :posts, through: :post_zen_categories

  # @param [Post] post
  def post?(post)
    post_zen_categories.where(post: post).exists?
  end

  # @param [Post] post
  def add_post(post)
    post_zen_categories.create(post: post)
  end

  # @param [Post] post
  def remove_post(post)
    post_zen_categories.where(post: post).destroy_all
  end
end
