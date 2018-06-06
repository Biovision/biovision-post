class AddOriginalTitleToPosts < ActiveRecord::Migration[5.2]
  def up
    add_column(:posts, :original_title, :string) unless column_exists?(:posts, :original_title)
  end

  def down
    # no need to rollback
  end
end
