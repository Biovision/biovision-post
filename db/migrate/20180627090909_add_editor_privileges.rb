class AddEditorPrivileges < ActiveRecord::Migration[5.2]
  def up
    group        = PrivilegeGroup.find_or_create_by(slug: 'editors')
    chief_editor = Privilege.find_or_create_by!(slug: 'chief_editor')
    children     = {
      editor:   'Редактор',
      reporter: 'Репортёр',
      blogger:  'Блогер'
    }

    children.each do |slug, name|
      next if Privilege.where(slug: slug).exists?
      child = Privilege.new(parent: chief_editor, slug: slug, name: name, administrative: false)

      if child.save
        group.add_privilege(child)
      end
    end

  end

  def down
    # No rollback needed
  end
end
