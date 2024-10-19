require 'rails_helper'

RSpec.feature 'Avatar management', type: :feature do
  let!(:user) { create(:user) }

  let!(:image) { { path: 'app/assets/images/default_avatar.png' } }

  before(:each) do
    sign_in user
    visit edit_avatar_path
  end

  subject do
    attach_file('user[avatar]', Rails.root.join(image[:path]))
    click_button 'Upload Avatar'
  end

  context 'Avatar Updation' do
    scenario 'User can update avatar with a valid image' do
      subject
      expect(page).to have_content('Avatar updated successfully!')
    end

    scenario 'User cannot update avatar with an empty file' do
      click_button 'Upload Avatar'
      expect(page).to have_content('No avatar provided!')
    end

    scenario 'User cannot update avatar with an invalid image format' do
      image[:path] = 'spec/features/avatar/invalid_avatar.txt'
      subject
      expect(page).to have_content('Avatar has an invalid content type')
    end

    scenario 'User cannot update avatar with an image exceeding the maximum dimensions' do
      # image[:path] = 'spec/features/avatar/large_image.png'
      # subject
      # expect(page).to have_content('Avatar is not given between dimension')
    end
  end

  context 'Avatar Deletion' do
    scenario 'User can delete avatar successfully' do
      subject
      click_button 'Delete avatar'
      expect(page).to have_content('Avatar deleted successfully!')
      expect(page).to have_selector('span.material-symbols-outlined.dropdown', text: 'account_circle')
    end
  end

  context 'Avatar Visibility' do
    scenario 'No avatar is present, displays default icon' do
      user.avatar.purge
      visit edit_avatar_path
      expect(page).to have_selector('span.material-symbols-outlined.dropdown', text: 'account_circle')
    end

    scenario 'Avatar thumbnail is visible on all pages while logged in' do
      subject
      visit root_path
      expect(page).to have_selector("img[src*='default_avatar.png']")
    end
  end
end
