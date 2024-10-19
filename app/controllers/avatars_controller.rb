class AvatarsController < ApplicationController
  before_action :authenticate_user!

  def update
    if params[:user].nil?
      flash[:error] = ['No avatar provided!']
    elsif current_user.update(avatar_params)
      flash[:notice] = 'Avatar updated successfully!'
    else
      flash[:error] = current_user.errors.full_messages
    end
    redirect_to edit_avatar_path
  end

  def destroy
    default_avatar_path = Rails.root.join('app/assets/images/default_avatar.jpeg')
    current_user.avatar.attach(
      io: File.open(default_avatar_path),
      filename: 'default_avatar.jpeg',
      content_type: 'image/png'
    )
    redirect_to edit_avatar_path, notice: 'Avatar deleted successfully!'
  end

  private

  def avatar_params
    params.require(:user).permit(:avatar)
  end
end
