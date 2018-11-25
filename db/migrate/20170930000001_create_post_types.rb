class CreatePostTypes < ActiveRecord::Migration[5.1]
  def up
    return if PostType.table_exists?

    create_table :post_types do |t|
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

  def down
    drop_table :post_types if PostType.table_exists?
  end

  def create_default_types
    PostType.create(slug: 'blog_post', name: 'Запись в блоге', default_category_name: 'Блог')
    PostType.create(slug: 'article', name: 'Статья', default_category_name: 'Статьи')
    PostType.create(slug: 'news', name: 'Новость', default_category_name: 'Новости')
  end

  def create_privileges
    group        = PrivilegeGroup.find_by(slug: 'editors') || PrivilegeGroup.create!(slug: 'editors', name: 'Редакторы')
    chief_editor = Privilege.find_by(slug: 'chief_editor') || Privilege.create(slug: 'chief_editor', name: 'Главный редактор')
    children     = {
      editor:   'Редактор',
      reporter: 'Репортёр',
      blogger:  'Блогер'
    }

    children.each do |slug, name|
      child = Privilege.new(parent: chief_editor, slug: slug, name: name, administrative: false)

      group.add_privilege(child) if child.save
    end
  end
end
