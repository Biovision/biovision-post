# frozen_string_literal: true

# Tables for post types, categories and tags
class CreatePostTypes < ActiveRecord::Migration[5.2]
  def up
    create_component
    create_post_types unless PostType.table_exists?
    create_post_categories unless PostCategory.table_exists?
    create_post_tags unless PostTag.table_exists?
    create_post_layouts unless PostLayout.table_exists?
  end

  def down
    drop_table :post_layouts if PostLayout.table_exists?
    drop_table :post_tags if PostTag.table_exists?
    drop_table :post_categories if PostCategory.table_exists?
    drop_table :post_types if PostType.table_exists?
  end

  private

  def create_post_types
    create_table :post_types, comment: 'Post type' do |t|
      t.timestamps
      t.boolean :active, default: true, null: false
      t.integer :posts_count, default: 0, null: false
      t.integer :category_depth, limit: 2, default: 0
      t.string :name, null: false
      t.string :slug, null: false
      t.string :url_part, null: false
      t.string :default_category_name
    end

    add_index :post_types, :slug, unique: true
    add_index :post_types, :name, unique: true

    create_default_types
  end

  def create_post_categories
    create_table :post_categories, comment: 'Post category' do |t|
      t.references :post_type, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.integer :parent_id
      t.timestamps
      t.integer :priority, limit: 2, default: 1, null: false
      t.integer :posts_count, default: 0, null: false
      t.boolean :locked, default: false, null: false
      t.boolean :visible, default: true, null: false
      t.boolean :deleted, default: false, null: false
      t.string :name, null: false
      t.string :nav_text
      t.string :slug, null: false
      t.string :long_slug, null: false
      t.string :meta_description
      t.string :parents_cache, default: '', null: false
      t.integer :children_cache, default: [], array: true, null: false
      t.jsonb :data, default: {}, null: false
    end

    add_foreign_key :post_categories, :post_categories, column: :parent_id, on_update: :cascade, on_delete: :cascade
  end

  def create_post_tags
    create_table :post_tags, comment: 'Post tag' do |t|
      t.timestamps
      t.references :post_type, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.integer :posts_count, default: 0, null: false
      t.string :name
      t.string :slug, index: true
    end
  end

  def create_post_layouts
    create_table :post_layouts, comment: 'Post layout' do |t|
      t.integer :posts_count, default: 0, null: false
      t.string :slug
      t.string :name
    end
  end

  def create_default_types
    items = {
      blog_post: ['Запись в блоге', 'blog_posts', 'Блог'],
      article: %w[Статья articles Статьи],
      news: %w[Новость news Новости]
    }

    items.each do |slug, data|
      PostType.create(slug: slug, name: data[0], url_part: data[1], default_category_name: data[2])
    end
  end

  def create_component
    BiovisionComponent.create(slug: 'posts')
  end
end
