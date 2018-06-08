class CreatePostPostTags < ActiveRecord::Migration[5.2]
  def up
    unless PostPostTag.table_exists?
      create_table :post_post_tags do |t|
        t.timestamps
        t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.references :post_tag, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      end
    end
  end

  def down
    if PostPostTag.table_exists?
      drop_table :post_post_tags
    end
  end
end
