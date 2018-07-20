class CreatePostTranslations < ActiveRecord::Migration[5.2]
  def up
    unless PostTranslation.table_exists?
      create_table :post_translations do |t|
        t.timestamps
        t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.references :language, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.integer :translated_post_id, null: false
      end

      add_foreign_key :post_translations, :posts, column: :translated_post_id, on_update: :cascade, on_delete: :cascade
    end
  end

  def down
    if PostTranslation.table_exists?
      drop_table :post_translations
    end
  end
end
