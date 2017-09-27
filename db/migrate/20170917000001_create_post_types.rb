class CreatePostTypes < ActiveRecord::Migration[5.1]
  def up
    unless PostType.table_exists?
      create_table :post_types do |t|
        t.timestamps
        t.integer :posts_count, default: 0, null: false
        t.string :name, null: false
        t.string :slug, null: false
      end

      PostType.create(slug: 'article', name: 'Статья')
    end
  end

  def down
    if PostType.table_exists?
      drop_table :post_types
    end
  end
end
