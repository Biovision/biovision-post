json.data @collection do |entity|
  json.id entity.id
  json.type entity.class.table_name
  json.attributes do
    json.(entity, :title, :publication_time, :language_id)
  end
  json.relationships do
    unless entity.user.nil?
      json.user do
        json.data do
          json.id entity.user_id
          json.type entity.user.class.table_name
        end
      end
    end
    json.post_type do
      json.data do
        json.id entity.post_type_id
        json.type PostType.table_name
      end
    end
  end
  json.meta do
    json.html render(partial: 'admin/posts/entity/in_search', formats: [:html], locals: { entity: entity })
  end
end
