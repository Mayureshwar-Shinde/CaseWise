class HomeController < ApplicationController
  def homepage
    if User.count == 0
      user = User.new(
                first_name: 'Admin',
                last_name: 'Casewise',
                age: 20,
                date_of_birth: "2000-01-01",
                role_type: 'case_manager',
                email: 'admin@gmail.com',
                password: 'password'
              )
      user.save
    end
  end
end
