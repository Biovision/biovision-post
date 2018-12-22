class AddRatingToPosts < ActiveRecord::Migration[5.2]
  def up
    unless column_exists?(:posts, :allow_votes)
      add_column :posts, :allow_votes, :boolean, default: true, null: false
    end
    unless column_exists?(:posts, :rating)
      add_column :posts, :rating, :float, default: 0.0, null: false
    end
  end

  def down
    # no rollback needed
  end
end
