require 'rails_helper'

RSpec.feature 'New Registration management', type: :feature do

  let(:user) { build(:user) }
  let(:user2) { create(:user) }

  subject do
    visit new_user_registration_path
    fill_in 'First name', with: user.first_name
    fill_in 'Last name', with: user.last_name
    fill_in 'Age', with: user.age
    fill_in 'Date of birth', with: user.date_of_birth
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    fill_in 'Password confirmation', with: user.password_confirmation
    click_button 'Sign up'
  end

  context 'User can sign up' do
    scenario 'with valid details' do
      subject
      expect(page).to have_text("Welcome , #{user.first_name}!")
    end
  end

  context 'User cannot sign up' do
    scenario 'with blank fields' do
      user.email = nil
      user.password = nil
      subject
      expect(page).to have_content("can't be blank")
    end

    scenario 'when password length is short' do
      user.password = 'short'
      subject
      expect(page).to have_content('Password is too short')
    end

    scenario 'with invalid email format' do
      user.email = 'invalidemail'
      subject
      expect(page).to have_content('Email is invalid')
    end

    scenario 'with future date of birth' do
      user.date_of_birth = '2090-01-01'
      subject
      expect(page).to have_content('Date of birth must be in the past')
    end

    scenario 'with invalid age format' do
      user.age = 'twentyfive'
      subject
      expect(page).to have_content('1 error prohibited this user from being saved')
    end

    scenario 'with valid details and additional validation' do
      user.age = -9
      subject
      expect(page).to have_content('Age must be greater than 0')
    end

    scenario 'with duplicate email' do
      user.email = user2.email
      subject
      expect(page).to have_content('Email has already been taken')
    end

    scenario 'when password field does not match with password_confirmation field' do
      user.password = 'password1'
      user.password_confirmation = 'password2'
      subject
      expect(page).to have_content("Password confirmation doesn't match Password")
    end
  end
end
