# frozen_string_literal: true

# Convert privilege-based links to component-user links
class ConvertPostPrivileges < ActiveRecord::Migration[5.2]
  def up
    return unless Privilege.table_exists?

    @handler = Biovision::Components::BaseComponent.handler('posts')

    convert_chief_editors
    convert_editors
  end

  def down
    # No rollback needed
  end

  private

  def convert_chief_editors
    privilege = Privilege.find_by(slug: 'chief_editor')

    return if privilege.nil?

    data = { chief_editor: true }

    privilege.users.each do |user|
      @handler.update_privileges(user, data)
    end
  end

  def convert_editors
    privilege = Privilege.find_by(slug: 'editor')

    return if privilege.nil?

    type_ids = PostType.pluck(:id)

    criteria = {
      biovision_component: @handler.component
    }

    privilege.users.each do |user|
      criteria[:user] = user
      link = BiovisionComponentUser.find_or_create_by(criteria)

      link.data['editor'] = true
      link.save!

      member = EditorialMember.find_or_create_by(user: user)
      type_ids.each do |id|
        EditorialMemberPostType.create(editorial_member: member, post_type_id: id)
      end
    end
  end
end
