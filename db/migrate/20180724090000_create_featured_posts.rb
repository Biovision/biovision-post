class CreateFeaturedPosts < ActiveRecord::Migration[5.2]
  def up
    unless FeaturedPost.table_exists?
      create_table :featured_posts do |t|
        t.timestamps
        t.references :language, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.integer :priority, limit: 2, null: false, default: 1
      end
    end
  end

  def down
    if FeaturedPost.table_exists?
      drop_table :featured_posts
    end
  end
end
