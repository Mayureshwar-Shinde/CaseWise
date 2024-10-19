class CreateUser < ActiveInteraction::Base
  string :first_name
  string :last_name
  integer :age
  date :date_of_birth
  string :email
  string :password

  def execute
    user = User.new(inputs)
    errors.merge!(user.errors) unless user.save
    user
  end
end