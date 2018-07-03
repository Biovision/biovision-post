json.data do
  json.id @entity.id
  json.type @entity.class.table_name
  json.attributes do
    json.(@entity, :priority)
  end
  json.relationships do
    json.post do
      json.id @entity.post_id
      json.type Post.table_name
    end
    json.other_post do
      json.id @entity.other_post_id
      json.type Post.table_name
    end
  end
  json.meta do
    json.html render(partial: 'admin/post_links/entity/in_list', formats: [:html], locals: { entity: @entity })
  end
end