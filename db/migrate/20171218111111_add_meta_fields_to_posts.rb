class AddMetaFieldsToPosts < ActiveRecord::Migration[5.1]
  def up
    unless column_exists?(:posts, :translation)
      add_column :posts, :translation, :boolean, default: false, null: false
    end

    add_column :posts, :meta_title, :string unless column_exists?(:posts, :meta_title)
    add_column :posts, :meta_keywords, :string unless column_exists?(:posts, :meta_keywords)
    add_column :posts, :meta_description, :string unless column_exists?(:posts, :meta_description)
  end

  def down
    # No need to rollback
  end
end
