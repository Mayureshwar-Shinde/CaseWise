class Users::RegistrationsController < Devise::RegistrationsController

  def create
    super
    default_avatar_path = Rails.root.join('app/assets/images/default_avatar.jpeg')
    current_user.avatar.attach(
            io: File.open(default_avatar_path),
            filename: 'default_avatar.jpeg',
            content_type: 'image/png'
          )
    # UserMailer.welcome_email(resource).deliver_now
  end

  def destroy
    redirect_to edit_registration_path(resource), alert: "Not allowed!"
  end

  protected

  def update_resource(resource, params)
    return super if params['password']&.present?
    resource.update_without_password(params.except('current_password'))
  end

end
