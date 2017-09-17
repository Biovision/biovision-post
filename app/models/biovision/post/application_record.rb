module Biovision
  module Post
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
