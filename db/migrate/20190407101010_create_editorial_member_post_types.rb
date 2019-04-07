# frozen_string_literal: true

# Create table for link between editorial member and post type
class CreateEditorialMemberPostTypes < ActiveRecord::Migration[5.2]
  def up
    return if EditorialMemberPostType.table_exists?

    create_table :editorial_member_post_types, comment: 'Available post type for editorial member' do |t|
      t.references :editorial_member, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :post_type, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
    end
  end

  def down
    drop_table :editorial_member_post_types if EditorialMemberPostType.table_exists?
  end
end
