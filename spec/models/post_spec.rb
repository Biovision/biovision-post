require 'rails_helper'

RSpec.describe Post, type: :model, focus: true do
  subject { build :post }

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  describe 'before validation' do
    it 'normalizes blank slug' do
      subject.title = 'TEST'
      subject.slug = ''
      subject.valid?
      expect(subject.slug).to eq('test')
    end

    it 'keeps non-blank slug intact (but lower-cased)' do
      subject.title = 'New post'
      subject.slug = 'Test'
      subject.valid?
      expect(subject.slug).to eq('test')
    end
  end
end
