require 'rails_helper'

RSpec.feature 'Login management', type: :feature do

  let!(:user) { create(:user) }

  subject do
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
  end

  context 'User fails to sign in' do
    scenario 'when password is kept blank' do
      user.password = nil
      subject
      expect(page).to have_content('Invalid Email or password.')
    end

    scenario 'when email is kept blank' do
      user.email = nil
      subject
      expect(page).to have_content('Invalid Email or password.')
    end

    scenario 'with invalid details' do
      user.email = 'wrong@example.com'
      user.password = 'wrongpassword'
      subject
      expect(page).to have_content('Invalid Email or password.')
    end
  end

  context 'User signs in successfully' do
    scenario 'with valid details' do
      subject
      expect(page).to have_content('Signed in successfully.')
    end
  end
end
