require 'rails_helper'

RSpec.shared_examples_for 'normalizes_priority' do |range|
  describe 'before validation' do
    it 'normalizes too low priority' do
      subject.priority = range.first - 1
      subject.valid?
      expect(subject.priority).to eq(range.first)
    end

    it 'normalizes too high priority' do
      subject.priority = range.last + 1
      subject.valid?
      expect(subject.priority).to eq(range.last)
    end
  end
end
