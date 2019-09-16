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

      # @param [Symbol] name
      def group?(name)
        case name
        when :chief
          allow? 'chief_editor', 'deputy_chief_editor'
        else
          allow? 'chief_editor', 'deputy_chief_editor', 'editor'
        end
      end

      def show_dashboard?
        return true if user.super_user?
        return true if group?(:chief)

        criterion = { editorial_member: EditorialMember[user] }
        editor = EditorialMemberPostType.where(criterion).exists?
        editor || Post.owned_by(user).exists?
      end

      # @param [PostType|String|Symbol] type
      def allow_post_type?(type)
        return false if user.nil?
        return true if user.super_user?
        return true if group?(:chief)

        criteria = {
          editorial_member: EditorialMember[user],
          post_type: type.is_a?(PostType) ? type : PostType[type]
        }
        EditorialMemberPostType.where(criteria).exists?
      end

      def editable?(entity)
        return true if group?(:chief)

        entity.owned_by?(user)
      end

      # @param [Post] entity
      def edit_path(entity)
        if group?(:chief)
          "/posts/#{entity.id}/edit"
        else
          "/my/posts/#{entity.id}/edit"
        end
      end
    end
  end
end
