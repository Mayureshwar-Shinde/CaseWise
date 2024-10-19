class UpdateUser < ActiveInteraction::Base
  object :user, class: User
  string :first_name, :last_name, :email, :password, default: nil
  integer :age, default: nil
  date :date_of_birth, default: nil

  def execute
    errors.merge!(user.errors) unless user.update(inputs.except(:user).compact)
    user
  end
end
