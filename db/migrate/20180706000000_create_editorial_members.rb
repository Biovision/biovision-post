# frozen_string_literal: true

# Table for editorial members
class CreateEditorialMembers < ActiveRecord::Migration[5.2]
  def up
    return if EditorialMember.table_exists?

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

  def down
    drop_table :editorial_members if EditorialMember.table_exists?
  end
end
