# frozen_string_literal: true

# Renames post image author to source
class RenamePostImageSource < ActiveRecord::Migration[5.2]
  def up
    rename_post_fields unless column_exists?(:posts, :image_source_name)
    rename_post_image_fields unless column_exists?(:post_images, :source_name)
  end

  def down
    # No rollback needed
  end

  private

  def rename_post_fields
    rename_column :posts, :image_author_name, :image_source_name
    rename_column :posts, :image_author_link, :image_source_link

  end

  def rename_post_image_fields
    rename_column :post_images, :owner_name, :source_name
    rename_column :post_images, :owner_link, :source_link
  end
end
