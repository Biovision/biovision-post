# frozen_string_literal: true

# Add url part field to post types
class AddUrlPartToPostTypes < ActiveRecord::Migration[5.2]
  def up
    return if column_exists?(:post_types, :url_part)

    add_column :post_types, :url_part, :string

    map_url_parts
  end

  def down
    # No rollback needed
  end

  private

  def map_url_parts
    mapping = { article: :articles, news: :news, blog_post: :blog_posts }
    mapping.each do |slug, url_part|
      post_type = PostType.find_by_slug(slug)
      post_type&.update!(url_part: url_part)
    end
  end
end
