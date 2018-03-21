class CreatePostReferences < ActiveRecord::Migration[5.1]
  def up
    unless PostReference.table_exists?
      create_table :post_references do |t|
        t.timestamps
        t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.integer :priority, limit: 2, default: 1, null: false
        t.string :authors
        t.string :title, null: false
        t.string :url
        t.string :publishing_info
      end
    end
  end

  def down
    if PostReference.table_exists?
      drop_table :post_references
    end
  end
end
