require 'rails_helper'

RSpec.feature 'Update Profile Management', type: :feature do

  let!(:user) { create(:user) }
  let!(:valid_attributes) { attributes_for(:user) }
  let!(:attributes) { Hash.new }

  before do
    sign_in user
    visit edit_user_registration_path
  end

  subject do
    attributes.compact!
    attributes.each { |key, value| fill_in key.to_s.gsub('_', ' ').capitalize, with: value }
    click_button 'Update'
  end

  def update_password(new_password, confirmation, current)
    attributes[:password] = new_password
    attributes[:password_confirmation] = confirmation
    attributes[:current_password] = current
    subject
  end

  context 'User can update profile' do
    scenario 'with valid details' do
      attributes.merge!(valid_attributes, password: nil, password_confirmation: nil)
      subject
      user.reload
      expect(page).to have_text('Your account has been updated successfully.')
      expect(user.first_name).to eq(attributes[:first_name])
      expect(user.last_name).to eq(attributes[:last_name])
      expect(user.age).to eq(attributes[:age])
      expect(user.date_of_birth).to eq(attributes[:date_of_birth])
      expect(user.email).to eq(attributes[:email].downcase)
    end

    scenario 'password with correct current password' do
      update_password('newpassword', 'newpassword', user.password)
      expect(page).to have_content('Your account has been updated successfully.')
    end
  end

  context 'User cannot update profile' do
    scenario 'with blank fields' do
      attributes[:first_name] = ''
      attributes[:last_name] = ''
      attributes[:age] = ''
      attributes[:date_of_birth] = ''
      subject
      expect(page).to have_content("can't be blank")
    end

    scenario 'password with incorrect current password' do
      update_password('newpassword', 'newpassword', 'incorrect')
      expect(page).to have_content('Current password is invalid')
    end

    scenario 'when password is too short' do
      update_password('short', 'short', user.password)
      expect(page).to have_content('Password is too short')
    end

    scenario 'with future date of birth' do
      attributes[:date_of_birth] = '2090-01-01'
      subject
      expect(page).to have_content('Date of birth must be in the past')
    end

    scenario 'with invalid age format' do
      attributes[:age] = -9
      subject
      expect(page).to have_content('Age must be greater than 0')
    end

    scenario 'when password confirmation does not match password' do
      update_password('password1', 'password2', user.password)
      expect(page).to have_content("Password confirmation doesn't match Password")
    end

    scenario 'with duplicate email' do
      user2 = create(:user)
      attributes[:email] = user2.email
      subject
      expect(page).to have_content('Email has already been taken')
    end
  end

  context 'User cancels account' do
    scenario 'successfully' do
      click_button 'Cancel my account'
      expect(page).to have_text('Bye! Your account has been successfully cancelled.')
    end
  end
end
