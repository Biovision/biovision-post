class AmendEditorialMemberAbout < ActiveRecord::Migration[5.2]
  def up
    EditorialMember.order('id asc').each do |entity|
      next if entity.about[0] == '<'

      entity.update! about: "<p>#{entity.about.gsub(/\r?\n/, '</p><p>')}</p>"
    end
  end

  def down
    # No rollback needed
  end
end
