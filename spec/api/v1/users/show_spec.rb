require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  describe 'GET #show' do

    let(:user) { create(:user) }
    let!(:token) { Token.create }

    subject { get api_v1_user_path(user.id), headers: { 'Authorization' => token.value } }

    context 'with valid token' do
      context 'when user exists' do
        it 'returns the response in JSON format' do
          subject
          expect(response.content_type).to eq 'application/json; charset=utf-8'
        end

        it 'returns the ok status' do
          subject
          expect(response).to have_http_status(:ok)
        end

        it 'returns valid user details' do
          subject
          json = json(response)
          expect(json['id']).to eq(user.id)
          expect(json['first_name']).to eq(user.first_name)
          expect(json['last_name']).to eq(user.last_name)
          expect(json['email']).to eq(user.email)
          response_created_at = DateTime.parse(json['created_at']).strftime('%Y-%m-%d %H:%M:%S')
          expect(response_created_at).to eq(user.created_at.strftime('%Y-%m-%d %H:%M:%S'))
        end
      end

      context 'when user does not exist' do
        it 'returns a not found status' do
          user.id = 999_999
          subject
          expect(response).to have_http_status(:not_found)
          expect(json(response)['error']).to eq('User not found')
        end
      end
    end

    context 'with an invalid token' do
      it 'denies access and does not return the user' do
        token.value = 'invalidtoken'
        subject
        expect(response).to have_http_status(:unauthorized)
        expect(json(response)['error']).to eq('Unauthorized access')
      end
    end

    context 'with no token' do
      it 'denies access and does not return the user' do
        get api_v1_user_path(user.id)
        expect(response).to have_http_status(:unauthorized)
        expect(json(response)['error']).to eq('Unauthorized access')
      end
    end
  end
end
