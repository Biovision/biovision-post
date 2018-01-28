class AddLanguageToPosts < ActiveRecord::Migration[5.1]
  def up
    unless column_exists?(:posts, :language_id)
      add_reference :posts, :language, foreign_key: { on_update: :cascade, on_delete: :nullify }
    end
  end

  def down
  #   no rollback
  end
end
