# frozen_string_literal: true

# Tables for Yandex.zen categories and links for post and category
class CreateZenCategories < ActiveRecord::Migration[5.2]
  def up
    create_zen_categories unless ZenCategory.table_exists?
    create_post_zen_categories unless PostZenCategory.table_exists?
  end

  def down
    drop_table :post_zen_categories if PostZenCategory.table_exists?
    drop_table :zen_categories if ZenCategory.table_exists?
  end

  private

  def create_zen_categories
    create_table :zen_categories, comment: 'Category for Yandex.zen' do |t|
      t.timestamps
      t.string :name, index: true, null: false
      t.integer :posts_count, default: 0, null: false
    end
  end

  def create_post_zen_categories
    create_table :post_zen_categories, comment: 'Link between post and Yandex.zen category' do |t|
      t.references :post, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :zen_category, null: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.timestamps
    end
  end

  def seed_categories
    %w[
      Авто Война Дизайн Дом Еда Здоровье Знаменитости Игры Кино Культура
      Литература Мода Музыка Наука Общество Политика Природа Происшествия
      Психология Путешествия Спорт Технологии Фотографии Хобби Экономика Юмор
    ].each do |name|
      ZenCategory.create(name: name)
    end
  end
end
