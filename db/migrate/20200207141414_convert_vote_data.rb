# frozen_string_literal: true

# Move legacy votes component fields to data
class ConvertVoteData < ActiveRecord::Migration[5.2]
  def up
    return unless column_exists?(:posts, :vote_result)

    Post.order('id asc').each do |post|
      post.data['votes'] = {
        up: post.upvote_count,
        down: post.downvote_count,
        total: post.vote_result
      }
      post.save!
    end

    remove_column :posts, :upvote_count
    remove_column :posts, :downvote_count
    remove_column :posts, :vote_result
  end

  def down
    # No rollback needed
  end
end
