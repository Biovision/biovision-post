# This migration comes from biovision_base_engine (originally 20180117160000)
class CreateUserLanguages < ActiveRecord::Migration[5.1]
  def up
    unless UserLanguage.table_exists?
      create_table :user_languages do |t|
        t.timestamps
        t.references :user, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.references :language, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      end
    end
  end

  def down
    if UserLanguage.table_exists?
      drop_table :user_languages
    end
  end
end
