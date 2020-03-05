# frozen_string_literal: true

require 'biovision/base'
require 'carrierwave'
require 'carrierwave-bombshelter'
require 'mini_magick'

module Biovision
  module Post
    # Initialization of the engine
    class Engine < ::Rails::Engine
      initializer 'biovision_post.load_base_methods' do
        require_dependency 'biovision/post/decorators/controllers/profiles_controller_decorator'
      end

      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_bot, :dir => 'spec/factories'
      end

      config.assets.precompile << %w[admin.scss biovision/base/**/*]
    end
  end
end
