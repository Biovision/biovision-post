json.data @collection do |entity|
  json.id entity.id
  json.type entity.class.table_name
  json.attributes do
    json.(entity, :title, :lead, :post_category_id)
  end
  json.meta do
    json.html_preview render(partial: 'posts/preview', formats: [:html], locals: { entity: entity })
  end
end
json.partial! 'shared/pagination', locals: { collection: @collection }
