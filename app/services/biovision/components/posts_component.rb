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

        entity = type.is_a?(PostType) ? type : PostType[type]

        types = Array(user_link!.data.dig('settings', 'types'))
        types.include?(entity.slug)
      end

      # @param [PostCategory] entity
      def allow_post_category?(entity)
        return false if user.nil?
        return true if user.super_user?
        return true if group?(:chief)

        ids = Array(user_link!.data.dig('settings', 'categories'))
        ids.map(&:to_i).include?(entity.id)
      end

      # @param [PostType] entity
      def allow_post_type(entity)
        return if user.nil?

        link = user_link!
        prepare_link_settings!(link)
        link.data['settings']['types'] += [entity.slug]
        link.data['settings']['types'].uniq!
        link.save
      end

      # @param [PostType] entity
      def disallow_post_type(entity)
        return if user.nil?

        link = user_link!
        prepare_link_settings!(link)
        link.data['settings']['types'] -= [entity.slug]
        link.save
      end

      # @param [PostCategory] entity
      def allow_post_category(entity)
        return if user.nil?

        link = user_link!
        prepare_link_settings!(link)
        ids = link.data['settings']['categories'] + [entity.subbranch_ids]
        link.data['settings']['categories'] = ids.map(&:to_i).uniq
        link.save
      end

      # @param [PostCategory] entity
      def disallow_post_category(entity)
        return if user.nil?

        link = user_link!
        prepare_link_settings!(link)
        categories = link.data['settings']['categories'].map(&:to_i)
        link.data['settings']['categories'] = categories - [entity.id]
        link.save
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

      # @param [BiovisionComponentUser] link
      def prepare_link_settings!(link)
        link.data['settings'] ||= {}
        link.data['settings']['types'] ||= []
        link.data['settings']['categories'] ||= []
      end
    end
  end
end
