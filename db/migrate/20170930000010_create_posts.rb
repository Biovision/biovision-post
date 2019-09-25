# frozen_string_literal: true

# Create tables for posts and post-related items
class CreatePosts < ActiveRecord::Migration[5.2]
  def up
    create_posts unless Post.table_exists?
    create_post_post_tags unless PostPostTag.table_exists?
    create_post_post_categories unless PostPostCategory.table_exists?
    create_post_images unless PostImage.table_exists?
    create_post_links unless PostLink.table_exists?
    create_post_translations unless PostTranslation.table_exists?
    create_post_references unless PostReference.table_exists?
    create_post_notes unless PostNote.table_exists?
    create_featured_posts unless FeaturedPost.table_exists?
    create_post_illustrations unless PostIllustration.table_exists?
    create_post_attachments unless PostAttachment.table_exists?
  end

  def down
    drop_table :post_attachments if PostAttachment.table_exists?
    drop_table :post_illustrations if PostIllustration.table_exists?
    drop_table :featured_posts if FeaturedPost.table_exists?
    drop_table :post_notes if PostNote.table_exists?
    drop_table :post_references if PostReference.table_exists?
    drop_table :post_translations if PostTranslation.table_exists?
    drop_table :post_links if PostLink.table_exists?
    drop_table :post_images if PostImage.table_exists?
    drop_table :post_post_categories if PostPostCategory.table_exists?
    drop_table :post_post_tags if PostPostTag.table_exists?
    drop_table :posts if Post.table_exists?
  end

  private

  def create_posts
    create_table :posts, comment: 'Post' do |t|
      t.references :user, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :post_type, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :language, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.integer :region_id
      t.integer :original_post_id
      t.references :agent, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.inet :ip
      t.timestamps
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
      t.boolean :avoid_parsing, default: false, null: false
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
      t.string :image_source_name
      t.string :image_source_link
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
      t.jsonb :data, default: {}, null: false
    end

    execute "create index posts_created_at_month_idx on posts using btree (date_trunc('month', created_at), post_type_id, user_id);"
    execute "create index posts_pubdate_month_idx on posts using btree (date_trunc('month', publication_time), post_type_id, user_id);"
    execute %(
      create or replace function posts_tsvector(title text, lead text, body text)
        returns tsvector as $$
          begin
            return (
              setweight(to_tsvector('russian', title), 'A') ||
              setweight(to_tsvector('russian', coalesce(lead, '')), 'B') ||
              setweight(to_tsvector('russian', body), 'C')
            );
          end
        $$ language 'plpgsql' immutable;
    )
    execute "create index posts_search_idx on posts using gin(posts_tsvector(title, lead, body));"

    add_foreign_key :posts, :posts, column: :original_post_id, on_update: :cascade, on_delete: :nullify

    add_index :posts, :created_at
    add_index :posts, :data, using: :gin

    Post.__elasticsearch__.create_index! if Gem.loaded_specs.key?('elasticsearch-model')
  end

  def create_post_post_tags
    create_table :post_post_tags, comment: 'Link between post and tag' do |t|
      t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :post_tag, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
    end
  end

  def create_post_post_categories
    create_table :post_post_categories, comment: 'Post in post category' do |t|
      t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :post_category, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
    end
  end

  def create_post_links
    create_table :post_links, comment: 'Link between posts' do |t|
      t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.integer :other_post_id, null: false
      t.timestamps
      t.integer :priority, limit: 2, default: 1, null: false
    end

    add_foreign_key :post_links, :posts, column: :other_post_id, on_update: :cascade, on_delete: :cascade
  end

  def create_post_images
    create_table :post_images, comment: 'Image in post gallery' do |t|
      t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
      t.boolean :visible, default: true, null: false
      t.integer :priority, limit: 2, default: 1, null: false
      t.uuid :uuid
      t.string :image
      t.string :image_alt_text
      t.string :caption
      t.string :source_name
      t.string :source_link
      t.text :description
    end
  end

  def create_post_translations
    create_table :post_translations, comment: 'Post translation' do |t|
      t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :language, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.integer :translated_post_id, null: false
      t.timestamps
    end

    add_foreign_key :post_translations, :posts, column: :translated_post_id, on_update: :cascade, on_delete: :cascade
  end

  def create_post_references
    create_table :post_references, comment: 'Reference in post body' do |t|
      t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
      t.integer :priority, limit: 2, default: 1, null: false
      t.string :authors
      t.string :title, null: false
      t.string :url
      t.string :publishing_info
    end
  end

  def create_post_notes
    create_table :post_notes, comment: 'Footnote for post' do |t|
      t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
      t.integer :priority, limit: 2, default: 1, null: false
      t.text :text, null: false
    end
  end

  def create_featured_posts
    create_table :featured_posts do |t|
      t.references :language, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
      t.integer :priority, limit: 2, null: false, default: 1
    end
  end

  def create_post_illustrations
    create_table :post_illustrations, comment: 'Inline post illustration' do |t|
      t.references :user, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.references :agent, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.inet :ip
      t.timestamps
      t.string :image
    end
  end

  def create_post_attachments
    create_table :post_attachments, comment: 'Attachment for post' do |t|
      t.references :post, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.uuid :uuid
      t.timestamps
      t.string :name
      t.string :file
    end
  end
end
