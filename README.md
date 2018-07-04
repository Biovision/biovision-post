Biovision::Post
===============

Модуль публикаций для сайтов на базе `biovision-base`. Используйте на свой
страх и риск без каких-либо гарантий.

Подключение
-----------

В Gemfile добавить использование гема:

```ruby
gem 'biovision-post', git: 'https://github.com/Biovision/biovision-post.git'
# gem 'biovision-post', path: '/Users/maxim/Projects/Biovision/gems/biovision-post'
```

Если нужен elasticsearch для поиска
-----------------------------------

В Gemfile добавить Elastic:

```ruby
gem 'elasticsearch-model'
gem 'elasticsearch-persistence'
```

В конфигурацию приложения (например, в `config/initializers/biovision.rb`) нужно 
добавить название индекса:

```ruby
  config.post_index_name = 'example_post'
```

Подключение фронтовой части
---------------------------

Добавить в `config/initializers/assets.rb`:

```ruby
Rails.application.config.assets.precompile << %w(biovision/post/*)
```

Добавить в `app/assets/javascripts/application.js`:

```js
//= require biovision/post/biovision-posts
```

Добавить в `app/assets/stylesheets/application.scss`, если нужна стилизация
«из коробки».

```scss
@import "biovision/post/posts";
```

Добавить в `app/assets/stylesheets/admin.scss` для стилизации административной
части модуля.

```scss
@import "biovision/post/admin/posts";
```

Микроразметка и Publisher Logo
------------------------------

При выводе публикаций используется разметка `schema.org`, в том числе параметр
publisher logo, картинка для которого находится в
`app/assets/images/biovision/post/publisher_logo.png`.

Сам шаблон, где выводятся соответствующие данные, находится в 
`app/views/posts/entity/_publisher.html.erb`.

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
