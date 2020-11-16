require 'spec_helper'
require 'support/requests/request_helpers'

describe 'api' do
  before(:each) do
    @user = create(:user, :with_company)
    @company = @user.companies.first
  end

  context 'invite two users with csv' do
    let(:email1) { 'gug@gug.com' }
    let(:email2) { 'gug2@gug.com' }
    subject do
      do_post invites_path,
           params: { invite: { invitable_id: @company.id,
                               invitable_type: @company.class.name,
                               email: [email1, email2].join(', '),
                               role: 'guest' } },
           **json_headers()
    end

    it 'returns json' do
      sign_in_with @user
      subject
      expect(response.content_type).to eq('application/json')
    end

    it 'responds with success' do
      sign_in_with @user
      subject
      expect(response).to have_http_status(201) # 201 is http status 'created'
    end

    it 'responds with json invites' do
      sign_in_with @user
      subject
      invites = JSON.parse(response.body)
      expect(invites.count).to be 2
      expect(invites[0]['email']).to eq email1
      expect(invites[1]['email']).to eq email2
      expect(invites[0]['recipient_id']).to be nil
      expect(invites[1]['recipient_id']).to be nil
      expect(invites[0]['sender_id']).to eq @user.id
      expect(invites[1]['sender_id']).to eq @user.id
      expect(invites[0]['invitable_id']).to eq @company.id
      expect(invites[1]['invitable_id']).to eq @company.id
      expect(invites[0]['invitable_type']).to eq @company.class.name
      expect(invites[1]['invitable_type']).to eq @company.class.name
      expect(invites[0]['role']).to eq 'guest'
      expect(invites[1]['role']).to eq 'guest'
    end
  end

  context 'invite with duplicated emails' do
    subject do
      do_post invites_path,
           params: { invite: { invitable_id: @company.id,
                               invitable_type: @company.class.name,
                               email: ["gaug@gmail.com", "gaug2@gmail.com", "gaug@gmail.com"].join(', '),
                               role: 'guest' } },
           **json_headers()
    end

    it 'returns json' do
      sign_in_with @user
      subject
      expect(response.content_type).to eq('application/json')
    end

    it 'responds with success' do
      sign_in_with @user
      subject
      expect(response).to have_http_status(201) # 201 is http status 'created'
    end

    it 'responds with json invites' do
      sign_in_with @user
      subject
      invites = JSON.parse(response.body)
      expect(invites.count).to be 2
      expect(invites[0]['email']).to eq email1
      expect(invites[1]['email']).to eq email2
      expect(invites[0]['recipient_id']).to be nil
      expect(invites[1]['recipient_id']).to be nil
      expect(invites[0]['sender_id']).to eq @user.id
      expect(invites[1]['sender_id']).to eq @user.id
      expect(invites[0]['invitable_id']).to eq @company.id
      expect(invites[1]['invitable_id']).to eq @company.id
      expect(invites[0]['invitable_type']).to eq @company.class.name
      expect(invites[1]['invitable_type']).to eq @company.class.name
      expect(invites[0]['role']).to eq 'guest'
      expect(invites[1]['role']).to eq 'guest'
    end
  end
end
