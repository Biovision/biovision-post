require 'rails_helper'

RSpec.shared_examples_for 'sets_next_priority_for_post_child' do
  describe 'after initialize' do
    it 'sets next priority' do
      subject.save!
      entity = subject.class.new(post: subject.post)
      expect(entity.priority).to eq(subject.priority + 1)
    end
  end
end
