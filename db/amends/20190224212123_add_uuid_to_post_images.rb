class AddUuidToPostImages < ActiveRecord::Migration[5.2]
  def up
    return if column_exists?(:post_images, :uuid)
    add_column :post_images, :uuid, :uuid
  end

  def down
    # No rollback needed
  end
end
