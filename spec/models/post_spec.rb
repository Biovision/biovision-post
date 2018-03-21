require 'rails_helper'

RSpec.describe Post, type: :model do
  subject { build :post }

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  describe 'after initialize' do
    it 'generates uuid if needed' do
      expect(Post.new.uuid).not_to be_nil
    end
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

    it 'generates transliterated slug from title' do
      subject.title = 'Проверка'
      subject.valid?
      expect(subject.slug).to eq('proverka')
    end
  end

  describe 'before_save' do
    it 'prepares parsed body' do
      subject.save
      expect(subject.parsed_body).not_to be_blank
    end
  end

  describe 'validation' do
    it 'fails with invalid slug' do
      subject.slug = 'invalid slug'
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:slug)
    end

    it 'fails with too long slug' do
      subject.slug = 'a' * 201
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:slug)
    end

    it 'fails without title' do
      subject.title = ' '
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:title)
    end

    it 'fails with too long title' do
      subject.title = 'A' * 141
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:title)
    end

    it 'fails without body' do
      subject.body = ' '
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:body)
    end

    it 'fails with too long body' do
      subject.body = 'a' * 50001
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:body)
    end

    it 'fails with too long lead' do
      subject.lead = 'A' * 351
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:lead)
    end

    it 'fails without user' do
      subject.user = nil
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:user)
    end

    it 'fails without post type' do
      subject.post_type = nil
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:post_type)
    end

    it 'fails when post category belongs to other post type' do
      subject.post_category = create(:post_category)
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:post_category)
    end

    it 'fails with too long author name' do
      subject.author_name = 'A' * 251
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:author_name)
    end

    it 'fails with too long author title' do
      subject.author_title = 'A' * 251
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:author_title)
    end

    it 'fails with too long author url' do
      subject.author_url = 'http://' + 'a' * 244
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:author_url)
    end

    it 'fails with too long image name' do
      subject.image_name = 'A' * 251
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:image_name)
    end

    it 'fails with too long image author name' do
      subject.image_author_name = 'A' * 251
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:image_author_name)
    end

    it 'fails with too long image author link' do
      subject.image_author_link = 'http://' + 'a' * 244
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:image_author_link)
    end
  end
end
