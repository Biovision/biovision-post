class CreateZenCategories < ActiveRecord::Migration[5.2]
  def up
    unless ZenCategory.table_exists?
      create_table :zen_categories do |t|
        t.timestamps
        t.string :name, index: true, null: false
        t.integer :posts_count, default: 0, null: false
      end
    end
  end

  def down
    if ZenCategory.table_exists?
      drop_table :zen_categories
    end
  end

  private

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
