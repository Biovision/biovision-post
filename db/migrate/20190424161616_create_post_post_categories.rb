# frozen_string_literal: true

# Create table for linking posts and categories many to many
class CreatePostPostCategories < ActiveRecord::Migration[5.2]
  def up
    create_post_post_categories unless PostPostCategory.table_exists?
    add_links if column_exists?(:posts, :post_category_id)
  end

  def down
    drop_table :post_post_categories if PostPostCategory.table_exists?
  end

  private

  def create_post_post_categories
    create_table :post_post_categories, comment: 'Post in post category' do |t|
      t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :post_category, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
    end
  end

  def add_links
    Post.pluck(:id, :post_category_id).each do |post_id, post_category_id|
      next if post_category_id.nil?

      PostPostCategory.create(post_category_id: post_category_id, post_id: post_id)
    end
  end
end
