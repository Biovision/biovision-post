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
    end
  end
end
