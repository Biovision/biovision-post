class AddMetaDescriptionToPostCategories < ActiveRecord::Migration[5.2]
  def up
    unless column_exists?(:post_categories, :meta_description)
      add_column :post_categories, :meta_description, :string
    end
  end

  def down
    # No need to rollback
  end
end
