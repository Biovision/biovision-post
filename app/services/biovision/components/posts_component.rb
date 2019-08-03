# frozen_string_literal: true

module Biovision
  module Components
    # Component for posts
    class PostsComponent < BaseComponent
      def use_parameters?
        false
      end

      def allow?(options = {})
        UserPrivilege.user_in_group?(user, :editors)
      end
    end
  end
end
