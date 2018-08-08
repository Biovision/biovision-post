class CreatePostZenCategories < ActiveRecord::Migration[5.2]
  def up
    unless PostZenCategory.table_exists?
      create_table :post_zen_categories do |t|
        t.timestamps
        t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.references :zen_category, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      end
    end
  end

  def down
    if PostZenCategory.table_exists?
      drop_table :post_zen_categories
    end
  end
end
