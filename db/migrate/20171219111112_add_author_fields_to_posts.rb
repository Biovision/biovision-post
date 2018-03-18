class AddAuthorFieldsToPosts < ActiveRecord::Migration[5.1]
  def up
    add_column :posts, :author_name, :string unless column_exists?(:posts, :author_name)
    add_column :posts, :author_title, :string unless column_exists?(:posts, :author_title)
    add_column :posts, :author_url, :string unless column_exists?(:posts, :author_url)
  end

  def down
    # no rollback
  end
end
