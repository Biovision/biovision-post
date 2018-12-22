class AddDefaultCategoryNameToPostTypes < ActiveRecord::Migration[5.2]
  def up
    unless column_exists?(:post_types, :default_category_name)
      add_column :post_types, :default_category_name, :string

      PostType.find_by(slug: 'news')&.update(default_category_name: 'Новости')
      PostType.find_by(slug: 'article')&.update(default_category_name: 'Статьи')
      PostType.find_by(slug: 'blog_post')&.update(default_category_name: 'Блог')
    end
  end

  def down
    # no rollback needed
  end
end
