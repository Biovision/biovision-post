class CreatePostNotes < ActiveRecord::Migration[5.1]
  def up
    unless PostNote.table_exists?
      create_table :post_notes do |t|
        t.timestamps
        t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.integer :priority, limit: 2, default: 1, null: false
        t.text :text, null: false
      end
    end
  end

  def down
    if PostNote.table_exists?
      drop_table :post_notes
    end
  end
end
