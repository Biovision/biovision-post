# frozen_string_literal: true

# Convert JSON column types to JSONB
class ConvertJsonPostColumns < ActiveRecord::Migration[5.2]
  def up
    change_posts if Post.columns_hash['data'].type == :json
  end

  def down
    # No rollback needed
  end

  private

  def change_posts
    queries = [
      %(alter table posts alter column data set data type jsonb using data::jsonb),
      %(alter table posts alter column data set default '{}'::jsonb)
    ]

    queries.each { |query| ActiveRecord::Base.connection.execute(query) }

    add_index :posts, :data, using: :gin
  end
end
