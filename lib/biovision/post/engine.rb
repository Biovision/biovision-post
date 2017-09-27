require 'biovision/base'
require 'carrierwave'
require 'carrierwave-bombshelter'
require 'mini_magick'

module Biovision
  module Post
    class Engine < ::Rails::Engine
      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      end

      config.assets.precompile << %w(admin.scss)
      config.assets.precompile << %w(biovision/base/icons/*)
      config.assets.precompile << %w(biovision/base/placeholders/*)
    end
  end
end
