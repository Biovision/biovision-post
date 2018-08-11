class AddExplicitToPosts < ActiveRecord::Migration[5.2]
  def up
    unless column_exists?(:posts, :explicit)
      add_column :posts, :explicit, :boolean, default: false, null: false
    end
  end

  def down
    # No rollback needed
  end
end
