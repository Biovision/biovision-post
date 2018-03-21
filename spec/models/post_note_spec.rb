require 'rails_helper'

RSpec.describe PostNote, type: :model do
  subject { build :post_note }

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  it_behaves_like 'requires_post'
  it_behaves_like 'sets_next_priority_for_post_child'
  it_behaves_like 'normalizes_priority', (1..32767)

  describe 'validation' do
    it 'fails without text' do
      subject.text = ' '
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:text)
    end

    it 'fails with too long text' do
      subject.text = 'A' * 1001
      expect(subject).not_to be_valid
      expect(subject.errors.messages).to have_key(:text)
    end
  end
end
