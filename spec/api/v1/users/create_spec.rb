require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do

  let(:user_attributes) { attributes_for(:user) }
  let(:token) { Token.create }
  subject { post api_v1_users_path, params: { user: user_attributes }, headers: { 'Authorization' => token.value } }

  describe 'POST #create' do
    context 'with a valid token' do
      context 'with valid attributes' do
        it 'creates a new user' do
          expect { subject }.to change(User, :count).by(1)
        end

        it 'returns a 201 response' do
          subject
          expect(response).to have_http_status(201)
        end

        it 'renders the user as JSON' do
          subject
          expected_json = JSON.parse(UserSerializer.new(User.last).to_json)
          expect(json(response)).to eq(expected_json)
        end
      end

      context 'with invalid attributes' do
        it 'does not create a new user without email' do
          user_attributes[:email] = nil
          expect { subject }.not_to change(User, :count)
        end

        it 'returns a 422 response' do
          user_attributes[:email] = nil
          subject
          expect(response).to have_http_status(422)
        end

        it 'renders error messages as JSON' do
          user_attributes[:password] = nil
          subject
          expect(json(response)['errors']).to include('Password is required')
        end

        it 'user not created with blank fields' do
          user_attributes[:email] = nil
          user_attributes[:password] = nil
          user_attributes[:first_name] = nil
          user_attributes[:last_name] = nil
          subject
          expect(json(response)['errors'].to_s).to include(
              '["First name is required", "Last name is required", "Email is required", "Password is required"]'
            )
        end

        it 'user is not created when password is too short' do
          user_attributes[:password] = 'short'
          subject
          expect(json(response)['errors']).to include('Password is too short (minimum is 6 characters)')
        end

        it 'does not create a new user with udplicate email' do
          existing_user = create(:user)
          user_attributes[:email] = existing_user.email
          subject
          expect(json(response)['errors']).to include('Email has already been taken')
        end

        it 'does not create a new user with invalid email format' do
          user_attributes[:email] = 'invalidemail'
          subject
          expect(json(response)['errors']).to include('Email is invalid')
        end

        it 'does not create user with invalid age' do
          user_attributes[:age] = -9
          subject
          expect(json(response)['errors']).to include('Age must be greater than 0')
        end
      end
    end

    context 'with an invalid token' do
      it 'denies access and does not create a new user' do
        token.value = 'invalidtoken'
        subject
        expect(response).to have_http_status(:unauthorized)
        expect(json(response)['error']).to eq('Unauthorized access')
      end
    end

    context 'with no token' do
      it 'denies access and does not create a new user' do
        expect { post api_v1_users_path, params: { user: user_attributes } }.not_to change(User, :count)
        expect(response).to have_http_status(:unauthorized)
        expect(json(response)['error']).to eq('Unauthorized access')
      end
    end

  end
end
