require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  describe 'PUT #update' do
    let!(:user) { create(:user) }
    let(:params) do
      {
        id: user.id,
        user: {}
      }
    end
    let!(:token) { Token.create }

    subject { put api_v1_user_path(user.id), params:, headers: { 'Authorization' => token.value } }

    context 'with valid token' do
      context 'with valid parameters' do
        it 'returns the response in JSON format' do
          params[:user][:first_name] = 'tom'
          subject
          expect(response.content_type).to eq 'application/json; charset=utf-8'
        end

        it 'returns the ok status' do
          subject
          expect(response).to have_http_status(:ok)
        end

        it 'updates the user with valid parameters' do
          params[:user][:first_name] = 'Updated'
          params[:user][:last_name] = 'Name'
          params[:user][:email] = 'updated@example.com'
          subject
          json = json(response)
          expect(json['first_name']).to eq('Updated')
          expect(json['last_name']).to eq('Name')
          expect(json['email']).to eq('updated@example.com')
        end
      end

      context 'with the invalid parameters' do
        it 'returns an unprocessable entity error for invalid email' do
          params[:user][:email] = 'invalidemail'
          subject
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json(response)['errors']).to include('Email is invalid')
        end

        it 'returns an unprocessable entity error for invalid password' do
          params[:user][:password] = 'short'
          subject
          expect(json(response)['errors']).to include('Password is too short (minimum is 6 characters)')
        end

        it 'returns an unprocessable entity error for invalid age' do
          params[:user][:age] = -1
          subject
          expect(json(response)['errors']).to include('Age must be greater than 0')
        end

        it 'returns an unprocessable entity error for invalid date of birth' do
          params[:user][:date_of_birth] = '01/01/9999'
          subject
          expect(json(response)['errors']).to include('Date of birth must be in the past')
        end

        it 'does not update the user' do
          params[:user][:first_name] = nil
          subject
          user.reload
          expect(user.first_name).not_to be_nil
        end

        it 'returns an error if the user is not found' do
          user.id = 999_999_999
          subject
          expect(response).to have_http_status(:not_found)
          expect(json(response)['error']).to eq('User not found')
        end
      end
    end

    context 'with an invalid token' do
      it 'denies access and does not update the user' do
        token.value = 'invalidtoken'
        subject
        expect(response).to have_http_status(:unauthorized)
        expect(json(response)['error']).to eq('Unauthorized access')
      end
    end

    context 'with no token' do
      it 'denies access and does not update the user' do
        put api_v1_user_path(user.id, params:)
        expect(response).to have_http_status(:unauthorized)
        expect(json(response)['error']).to eq('Unauthorized access')
      end
    end
  end
end
