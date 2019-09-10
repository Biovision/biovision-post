# frozen_string_literal: true

module Biovision
  module Components
    # Component for posts
    class PostsComponent < BaseComponent
      SLUG = 'posts'

      def self.privilege_names
        %w[chief_editor deputy_chief_editor editor]
      end

      def use_parameters?
        false
      end

      # @param [PostType|String|Symbol] type
      def allow_post_type?(type)
        return false if user.nil?
        return true if user.super_user?
        return true if allow?('chief_editor', 'deputy_chief_editor')

        criteria = {
          editorial_member: EditorialMember.find_by(user: user),
          post_type: type.is_a?(PostType) ? type : PostType['post_type']
        }
        EditorialMemberPostType.where(criteria).exists?
      end
    end
  end
end
