# frozen_string_literal: true

# Job for parsing post body
class PostBodyParserJob < ApplicationJob
  queue_as :default

  # @param [Integer] post_id
  def perform(post_id)
    post = Post.find_by(id: post_id)

    return if post.nil?

    post.update(body: PostManager.handler(post).parsed_body)
  end
end
