require 'rails_helper'

RSpec.describe Admin::PostTypesController, type: :controller do
  let(:entity) { create :post_type }

  before :each do
    allow(subject).to receive(:restrict_access)
  end

  describe 'get index' do
    before :each do
      get :index
    end

    it 'restricts access' do
      expect(subject).to have_received(:restrict_access)
    end
  end

  describe 'get show' do
    before :each do
      allow(entity.class).to receive(:find_by).and_return(entity)
      get :show, params: { id: entity.id }
    end

    it 'restricts access' do
      expect(subject).to have_received(:restrict_access)
    end

    it 'finds entity' do
      expect(entity.class).to have_received(:find_by)
    end
  end

  describe 'get post_categories' do
    pending
  end
end
