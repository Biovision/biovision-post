class CreatePostLinks < ActiveRecord::Migration[5.1]
  def up
    unless PostLink.table_exists?
      create_table :post_links do |t|
        t.timestamps
        t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.integer :other_post_id, null: false
        t.integer :priority, limit: 2, default: 1, null: false
      end

      add_foreign_key :post_links, :posts, column: :other_post_id, on_update: :cascade, on_delete: :cascade
    end
  end

  def down
    if PostLink.table_exists?
      drop_table :post_links
    end
  end
end
