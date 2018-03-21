require 'rails_helper'

RSpec.shared_examples_for 'requires_post' do
  describe 'validation' do
    it 'fails without post' do
      subject.post = nil
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:post)
    end
  end
end