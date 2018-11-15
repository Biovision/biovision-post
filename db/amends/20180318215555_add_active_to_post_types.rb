class AddActiveToPostTypes < ActiveRecord::Migration[5.1]
  def up
    unless column_exists? :post_types, :active
      add_column :post_types, :active, :boolean, default: true, null: false
    end
  end

  def down
    # no rollback
  end
end
