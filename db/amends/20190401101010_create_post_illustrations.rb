# frozen_string_literal: true

# Create table for post illustration uploaded with WYSIWYG
class CreatePostIllustrations < ActiveRecord::Migration[5.2]
  def up
    return if PostIllustration.table_exists?

    create_table :post_illustrations, comment: 'Inline post illustration' do |t|
      t.references :user, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.references :agent, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.inet :ip
      t.timestamps
      t.string :image
    end
  end

  def down
    drop_table :post_illustrations if PostIllustration.table_exists?
  end
end
