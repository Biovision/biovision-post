# frozen_string_literal: true

# Create tables for grouping post categories
class CreatePostGroups < ActiveRecord::Migration[5.2]
  def up
    create_post_groups unless PostGroup.table_exists?
    create_post_group_categories unless PostGroupCategory.table_exists?
    create_post_group_tags unless PostGroupTag.table_exists?
  end

  def down
    drop_table :post_group_tags if PostGroupTag.table_exists?
    drop_table :post_group_categories if PostGroupCategory.table_exists?
    drop_table :post_groups if PostGroup.table_exists?
  end

  private

  def create_post_groups
    create_table :post_groups, comment: 'Group of post categories and tags' do |t|
      t.integer :priority, limit: 2, default: 1, null: false
      t.boolean :visible, default: true, null: false
      t.timestamps
      t.string :slug
      t.string :name
      t.string :nav_text
    end
  end

  def create_post_group_categories
    create_table :post_group_categories, comment: 'Post category in group' do |t|
      t.references :post_group, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :post_category, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.integer :priority, limit: 2, default: 1, null: false
      t.timestamps
    end
  end

  def create_post_group_tags
    create_table :post_group_tags, comment: 'Post tag in group' do |t|
      t.references :post_group, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :post_tag, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.integer :priority, limit: 2, default: 1, null: false
      t.timestamps
    end
  end
end
