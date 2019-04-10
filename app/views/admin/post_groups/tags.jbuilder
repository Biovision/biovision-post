json.data @collection do |entity|
  json.id entity.id
  json.type entity.class.table_name
  json.attributes do
    json.call(entity, :name, :post_type_id, :posts_count)
  end
  json.meta do
    json.post_type entity.post_type.name
    json.checked @entity.tag?(entity)
    json.url tag_admin_post_group_path(id: @entity.id, tag_id: entity.id)
  end
end
