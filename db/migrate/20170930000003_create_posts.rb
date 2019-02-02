class CreatePosts < ActiveRecord::Migration[5.1]
  def up
    unless Post.table_exists?
      create_table :posts do |t|
        t.timestamps
        t.references :user, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.references :post_type, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.references :post_category, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.references :language, foreign_key: { on_update: :cascade, on_delete: :nullify }
        t.integer :region_id
        t.integer :original_post_id
        t.references :agent, foreign_key: { on_update: :cascade, on_delete: :nullify }
        t.inet :ip
        t.boolean :visible, default: true, null: false
        t.boolean :locked, default: false, null: false
        t.boolean :deleted, default: false, null: false
        t.boolean :approved, default: true, null: false
        t.boolean :show_owner, default: true, null: false
        t.boolean :allow_comments, default: true, null: false
        t.boolean :allow_votes, default: true, null: false
        t.boolean :translation, default: false, null: false
        t.boolean :explicit, default: false, null: false
        t.boolean :spam, default: false, null: false
        t.float :rating, default: 0.0, null: false
        t.integer :privacy, limit: 2, default: 0
        t.integer :comments_count, default: 0, null: false
        t.integer :view_count, default: 0, null: false
        t.integer :upvote_count, default: 0, null: false
        t.integer :downvote_count, default: 0, null: false
        t.integer :vote_result, default: 0, null: false
        t.integer :time_required, limit: 2
        t.datetime :publication_time
        t.uuid :uuid, null: false
        t.string :title, null: false
        t.string :slug, null: false, index: true
        t.string :image
        t.string :image_alt_text
        t.string :image_name
        t.string :image_author_name
        t.string :image_author_link
        t.string :original_title
        t.string :source_name
        t.string :source_link
        t.string :meta_title
        t.string :meta_keywords
        t.string :meta_description
        t.string :author_name
        t.string :author_title
        t.string :author_url
        t.string :translator_name
        t.text :lead
        t.text :body, null: false
        t.text :parsed_body
        t.string :tags_cache, array: true, default: [], null: false
      end

      execute "create index posts_created_at_month_idx on posts using btree (date_trunc('month', created_at), post_type_id, user_id);"
      execute "create index posts_pubdate_month_idx on posts using btree (date_trunc('month', publication_time), post_type_id, user_id);"

      add_foreign_key :posts, :posts, column: :original_post_id, on_update: :cascade, on_delete: :nullify

      add_index :posts, :created_at

      if Gem.loaded_specs.key?('elasticsearch-model')
        Post.__elasticsearch__.create_index!
      end
    end
  end

  def down
    if Post.table_exists?
      drop_table :posts
    end
  end
end
