require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  describe 'DELETE #destroy' do
    let!(:user) { create(:user) }
    let!(:token) { Token.create }

    subject { delete api_v1_user_path(user.id), headers: { 'Authorization' => token.value } }

    context 'with a valid token' do
      context 'when the user exists' do
        it 'deletes the user and returns success message' do
          expect { subject }.to change(User, :count).by(-1)
          expect(response).to have_http_status(:ok)
          expect(json(response)['message']).to eq('User deleted successfully')
        end
      end

      context 'when the user does not exist' do
        before { user.destroy }

        it 'returns a valid response' do
          subject
          expect(response).to have_http_status(:not_found)
          expect(response.content_type).to include('application/json')
        end

        it 'returns a not found error' do
          subject
          expect(json(response)['error']).to eq('User not found')
        end
      end
    end

    context 'with an invalid token' do
      it 'denies access and does not delete the user' do
        token.value = 'invalidtoken'
        subject
        expect(response).to have_http_status(:unauthorized)
        expect(json(response)['error']).to eq('Unauthorized access')
      end
    end

    context 'with no token' do
      it 'denies access and does not delete the user' do
        expect { delete api_v1_user_path(user.id) }.not_to change(User, :count)
        expect(response).to have_http_status(:unauthorized)
        expect(json(response)['error']).to eq('Unauthorized access')
      end
    end

  end
end
