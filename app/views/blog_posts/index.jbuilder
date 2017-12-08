json.data @collection do |entity|
  json.id entity.id
  json.type entity.class.table_name
  json.attributes do
    json.(entity, :title, :lead)
  end
  json.meta do
    json.html_preview render(partial: 'posts/preview', formats: [:html], locals: { entity: entity })
  end
end
unless @collection.next_page.blank?
  json.meta do
    json.next_page @collection.next_page
  end
end
json.partial! 'shared/pagination', locals: { collection: @collection }
