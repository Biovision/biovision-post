class CreatePostImages < ActiveRecord::Migration[5.2]
  def up
    unless PostImage.table_exists?
      create_table :post_images do |t|
        t.timestamps
        t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.boolean :visible, default: true, null: false
        t.integer :priority, limit: 2, default: 1, null: false
        t.string :image
        t.string :image_alt_text
        t.string :caption
        t.string :owner_name
        t.string :owner_link
        t.text :description
      end
    end
  end

  def down
    if PostImage.table_exists?
      drop_table :post_images
    end
  end
end
