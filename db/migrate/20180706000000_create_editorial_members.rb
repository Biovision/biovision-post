class CreateEditorialMembers < ActiveRecord::Migration[5.2]
  def up
    unless EditorialMember.table_exists?
      create_table :editorial_members do |t|
        t.timestamps
        t.references :user, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.boolean :visible, default: true, null: false
        t.integer :priority, limit: 2, default: 1, null: false
        t.string :title
        t.text :lead
        t.text :about
      end
    end
  end

  def down
    if EditorialMember.table_exists?
      drop_table :editorial_members
    end
  end
end
