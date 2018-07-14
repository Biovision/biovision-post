class CreatePostTypes < ActiveRecord::Migration[5.1]
  def up
    unless PostType.table_exists?
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
  end

  def down
    if PostType.table_exists?
      drop_table :post_types
    end
  end

  def create_default_types
    PostType.create(slug: 'blog_post', name: 'Запись в блоге', default_category_name: 'Блог')
    PostType.create(slug: 'article', name: 'Статья', default_category_name: 'Статьи')
    PostType.create(slug: 'news', name: 'Новость', default_category_name: 'Новости')
  end

  def create_privileges
    group        = PrivilegeGroup.find_by!(slug: 'editors')
    chief_editor = Privilege.find_by(slug: 'chief_editor') || Privilege.create(slug: 'chief_editor', name: 'Главный редактор')
    children     = {
      editor:   'Редактор',
      reporter: 'Репортёр',
      blogger:  'Блогер'
    }

    children.each do |slug, name|
      child = Privilege.new(parent: chief_editor, slug: slug, name: name, administrative: false)

      if child.save
        group.add_privilege(child)
      end
    end
  end
end
