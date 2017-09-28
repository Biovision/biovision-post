require 'rails_helper'

RSpec.describe PostType, type: :model do
  subject { build :post_type }

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  describe 'validation' do
    it 'fails without name' do
      subject.name = ' '
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:name)
    end

    it 'fails without slug' do
      subject.slug = ' '
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:slug)
    end

    it 'fails with too long name' do
      subject.name = 'a' * 51
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:name)
    end

    it 'fails with too long slug' do
      subject.slug = 'a' * 51
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:slug)
    end

    it 'fails with invalid slug' do
      subject.slug = 'wrong slug'
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:slug)
    end

    it 'fails with non-unique name' do
      create :post_type, name: subject.name
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:name)
    end

    it 'fails with non-unique slug' do
      create :post_type, slug: subject.slug
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:slug)
    end

    it 'fails with negative category_depth' do
      subject.category_depth = -1
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:category_depth)
    end

    it 'fails with too big category_depth' do
      subject.category_depth = 11
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:category_depth)
    end
  end
end
