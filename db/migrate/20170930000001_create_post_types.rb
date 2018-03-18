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
      end

      add_index :post_types, :slug, unique: true
      add_index :post_types, :name, unique: true

      PostType.create(slug: 'blog_post', name: 'Запись в блоге')
      PostType.create(slug: 'article', name: 'Статья')
      PostType.create(slug: 'news', name: 'Новость')
    end
  end

  def down
    if PostType.table_exists?
      drop_table :post_types
    end
  end
end
