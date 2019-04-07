# frozen_string_literal: true

# Table for editorial members
class CreateEditorialMembers < ActiveRecord::Migration[5.2]
  def up
    create_editorial_members unless EditorialMember.table_exists?
    create_member_post_types unless EditorialMemberPostType.table_exists?
  end

  def down
    drop_table :editorial_member_post_types if EditorialMemberPostType.table_exists?
    drop_table :editorial_members if EditorialMember.table_exists?
  end

  private

  def create_editorial_members
    create_table :editorial_members, comment: 'Editorial member' do |t|
      t.references :user, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
      t.boolean :visible, default: true, null: false
      t.integer :priority, limit: 2, default: 1, null: false
      t.string :title
      t.text :lead
      t.text :about
    end

  end

  def create_member_post_types
    create_table :editorial_member_post_types, comment: 'Available post type for editorial member' do |t|
      t.references :editorial_member, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :post_type, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
    end
  end
end
