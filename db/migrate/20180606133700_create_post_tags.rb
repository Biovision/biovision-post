class CreatePostTags < ActiveRecord::Migration[5.2]
  def up
    unless PostTag.table_exists?
      create_table :post_tags do |t|
        t.timestamps
        t.references :post_type, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.integer :posts_count, default: 0, null: false
        t.string :name
        t.string :slug, index: true
      end
    end
  end

  def down
    if PostTag.table_exists?
      drop_table :post_tags
    end
  end
end
