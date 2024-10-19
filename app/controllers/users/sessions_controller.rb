class Users::SessionsController < Devise::SessionsController

  def create
    super
    # UserMailer.login(resource).deliver_now
  end

end
