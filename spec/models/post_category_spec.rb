require 'rails_helper'

RSpec.describe PostCategory, type: :model do
  subject { build :post_category }

  let(:post_type) { subject.post_type }

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  describe 'after initialize' do
    it 'sets next priority' do
      subject.save!
      entity = PostCategory.new(post_type: post_type)
      expect(entity.priority).to eq(subject.priority + 1)
    end
  end

  describe 'after create' do
    before :each do
      post_type.update! category_depth: 1
      subject.save!
    end

    it 'caches parents' do
      entity = create(:post_category, parent: subject, post_type: post_type)
      expect(entity.parents_cache).to eq(subject.id.to_s)
    end

    it 'caches parent children' do
      entity = create(:post_category, parent: subject, post_type: post_type)
      expect(subject.children_cache).to eq([entity.id])
    end
  end

  describe 'before validation' do
    it 'normalizes too low priority' do
      subject.priority = 0
      subject.valid?
      expect(subject.priority).to eq(1)
    end

    it 'normalizes too high priority' do
      subject.priority = 101
      subject.valid?
      expect(subject.priority).to eq(100)
    end

    it 'normalizes blank slug' do
      subject.name = 'TEST'
      subject.slug = ''
      subject.valid?
      expect(subject.slug).to eq('test')
    end

    it 'keeps non-blank slug intact (but lower-cased)' do
      subject.name = 'New name'
      subject.slug = 'Test'
      subject.valid?
      expect(subject.slug).to eq('test')
    end

    it 'generates long slug' do
      subject.save!
      entity = build(:post_category, post_type: post_type, parent: subject)
      entity.valid?
      expect(entity.long_slug).to eq("#{subject.slug}_#{entity.slug}")
    end
  end

  describe 'validation' do
    before :each do
      post_type.update! category_depth: 1
    end

    it 'fails without name' do
      subject.name = ' '
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:name)
    end

    it 'fails with non-unique slug in post type' do
      subject.slug = 'test'
      create :post_category, post_type: post_type, slug: subject.slug
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:slug)
    end

    it 'passes with non-unique slug outside post type' do
      subject.slug = 'test'
      create :post_category, slug: subject.slug
      expect(subject).to be_valid
    end

    it 'fails with non-unique name in siblings' do
      create :post_category, name: subject.name, slug: 'other', post_type: post_type
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:name)
    end

    it 'passes with non-unique name outside same parent' do
      parent = create :post_category, post_type: post_type
      create :post_category, name: subject.name, slug: 'other', post_type: post_type, parent: parent
      expect(subject).to be_valid
    end

    it 'fails if post type for parent mismatches' do
      parent = create :post_category

      subject.parent = parent
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:parent_id)
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

    it 'fails when slug does not match pattern' do
      subject.slug = 'invalid slug'
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:slug)
    end

    it 'fails with too big branch depth' do
      post_type.category_depth = 0

      parent         = create :post_category, post_type: post_type
      subject.parent = parent
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:parent_id)
    end
  end
end
