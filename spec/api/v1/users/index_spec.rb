require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do

  let!(:users) { create_list(:user, 10) }
  let!(:user) { users.last }
  let(:params) { {} }
  let(:token) { Token.create }

  subject { get api_v1_users_path, params: , headers: { 'Authorization' => token.value } }

  describe 'GET /api/v1/users' do
    context 'with valid token' do
      context 'without query filters' do
        it 'responds with ok status' do
          subject
          expect(response).to have_http_status :ok
        end

        it 'returns a JSON response' do
          subject
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end

        it 'returns a list of users' do
          subject
          expect(json(response).size).to eq(10)
        end

        it 'returns a list of users with the correct attributes' do
          subject
          expect(json(response).first.keys).to eq(%w[id first_name last_name email age date_of_birth created_at updated_at])
        end

        it 'returns a list of users with the correct data types' do
          subject
          json = json(response).first
          expect(json['id']).to be_a(Integer)
          expect(json['first_name']).to be_a(String)
          expect(json['last_name']).to be_a(String)
          expect(json['email']).to be_a(String)
          expect(json['created_at']).to be_a(String)
        end

        it 'returns an empty list when there are no users' do
          User.delete_all
          subject
          expect(json(response)).to be_empty
        end
      end

      context 'with query filters' do
        it 'returns a list of users filtered by first name' do
          params[:first_name] = user.first_name
          subject
          expect(json(response).first['id']).to eq(user.id)
        end

        it 'returns a list of users filtered by last name' do
          params[:last_name] = user.last_name
          subject
          expect(json(response).first['id']).to eq(user.id)
        end

        it 'returns a list of users filtered by email' do
          params[:email] = user.email
          subject
          expect(json(response).size).to eq(1)
          expect(json(response).first['id']).to eq(user.id)
        end

        it 'returns a list of users filtered by multiple parameters' do
          params[:first_name] = user.first_name
          params[:last_name] = user.last_name
          params[:email] = user.email
          subject
          expect(json(response).size).to eq(1)
          expect(json(response).first['id']).to eq(user.id)
        end

        it 'returns an empty list when no users match the filter' do
          params[:first_name] = 'invalidfirstname'
          subject
          expect(json(response)).to be_empty
        end
      end
    end

    context 'with an invalid token' do
      it 'denies access and does not return the list of users' do
        token.value = 'invalidtoken'
        subject
        expect(response).to have_http_status(:unauthorized)
        expect(json(response)['error']).to eq('Unauthorized access')
      end
    end

    context 'with no token' do
      it 'denies access and does not return the list of users' do
        get api_v1_users_path
        expect(json(response).size).not_to eq(10)
        expect(response).to have_http_status(:unauthorized)
        expect(json(response)['error']).to eq('Unauthorized access')
      end
    end

  end
end
