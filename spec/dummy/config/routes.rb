Rails.application.routes.draw do
  mount Biovision::Post::Engine => "/biovision-post"
end
