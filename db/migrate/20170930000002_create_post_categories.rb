class CreatePostCategories < ActiveRecord::Migration[5.1]
  def up
    unless PostCategory.table_exists?
      create_table :post_categories do |t|
        t.timestamps
        t.references :post_type, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.integer :parent_id
        t.integer :priority, limit: 2, default: 1, null: false
        t.integer :posts_count, default: 0, null: false
        t.boolean :locked, default: false, null: false
        t.boolean :visible, default: true, null: false
        t.boolean :deleted, default: false, null: false
        t.string :name, null: false
        t.string :slug, null: false
        t.string :long_slug, null: false
        t.string :parents_cache, default: '', null: false
        t.integer :children_cache, default: [], array: true, null: false
      end

      add_foreign_key :post_categories, :post_categories, column: :parent_id, on_update: :cascade, on_delete: :cascade
    end
  end

  def down
    if PostCategory.table_exists?
      drop_table :post_categories
    end
  end
end
