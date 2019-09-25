# frozen_string_literal: true

# Add full-text search to posts table
class AddSearchIndexToPosts < ActiveRecord::Migration[5.2]
  def up
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
    execute 'create index posts_search_idx on posts using gin(posts_tsvector(title, lead, body));'
  end

  def down
    # no rollback needed
  end
end
