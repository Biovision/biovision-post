# frozen_string_literal: true

# Tables for post types, categories and tags
class CreatePostTypes < ActiveRecord::Migration[5.2]
  def up
    create_post_types unless PostType.table_exists?
    create_post_categories unless PostCategory.table_exists?
    create_post_tags unless PostTag.table_exists?
  end

  def down
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
      t.string :default_category_name
    end

    add_index :post_types, :slug, unique: true
    add_index :post_types, :name, unique: true

    create_default_types
    create_privileges
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
      t.string :slug, null: false
      t.string :long_slug, null: false
      t.string :meta_description
      t.string :parents_cache, default: '', null: false
      t.integer :children_cache, default: [], array: true, null: false
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

  def create_default_types
    items = {
      blog_post: ['Запись в блоге', 'Блог'],
      article: %w[Статья Статьи],
      news: %w[Новость Новости]
    }

    items.each do |slug, data|
      PostType.create(slug: slug, name: data[0], default_category_name: data[1])
    end
  end

  def create_privileges
    group        = PrivilegeGroup.find_by(slug: 'editors') || PrivilegeGroup.create!(slug: 'editors', name: 'Редакторы')
    chief_editor = Privilege.find_by(slug: 'chief_editor') || Privilege.create(slug: 'chief_editor', name: 'Главный редактор')
    children     = {
      editor: 'Редактор'
    }

    children.each do |slug, name|
      child = Privilege.new(parent: chief_editor, slug: slug, name: name, administrative: false)

      group.add_privilege(child) if child.save
    end
  end
end
