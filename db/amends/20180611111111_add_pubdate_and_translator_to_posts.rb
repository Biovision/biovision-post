class AddPubdateAndTranslatorToPosts < ActiveRecord::Migration[5.2]
  def up
    unless column_exists? :posts, :publication_time
      add_column :posts, :publication_time, :datetime
    end

    unless column_exists? :posts, :translator_name
      add_column :posts, :translator_name, :string
    end

    Post.where(publication_time: nil).order('id asc').each do |post|
      post.update! publication_time: post.created_at
    end
  end

  def down
    # no rollback needed
  end
end
