require 'rails_helper'

RSpec.describe User, type: :model do

  let!(:user) { build(:user) }

  context 'Should not be valid' do
    it 'when first_name is not present' do
      user.first_name = nil
      expect(user).not_to be_valid
    end

    it 'when last_name is not present' do
      user.last_name = nil
      expect(user).not_to be_valid
    end

    it 'when age is not present' do
      user.age = nil
      expect(user).not_to be_valid
    end

    it 'when date_of_birth is not present' do
      user.date_of_birth = nil
      expect(user).not_to be_valid
    end

    it 'when email is not present' do
      user.email = nil
      expect(user).not_to be_valid
    end

    it 'when password is not present' do
      user.password = nil
      expect(user).not_to be_valid
    end

    it 'when email is already been taken' do
      user2 = create(:user)
      user.email = user2.email
      expect(user).not_to be_valid
    end

  end

  context 'Should be valid if' do
    it 'with first_name, last_name, age, date_of_birth, email, password' do
      expect(user).to be_valid
    end

    it 'date_of_birth before current date' do
      user.date_of_birth = Date.yesterday
      expect(user).to be_valid
    end

    it 'age greater than or equal to 18' do
      user.age = 18
      expect(user).to be_valid
    end

    it 'password length with minimum 6 characters' do
      user.password = 'secure123'
      user.password_confirmation = 'secure123'
      expect(user).to be_valid
    end

    it 'email in proper desired format' do
      user.email = 'test@example.com'
      expect(user).to be_valid
    end

  end
end
