module Build
  class DatabaseBuilder
    def reset_data
      Audited::Audit.delete_all
      User.destroy_all
    end

    def create_users
      (1..4).each do
        admin = FactoryBot.create(:user, role_type: 'case_manager')
        dispute_analyst = FactoryBot.create(:user)
        (1..10).each { FactoryBot.create(:case, user: admin, assigned_to: dispute_analyst) }
      end
      User.first.update(email: 'tomcat@gmail.com', first_name: 'Tom', last_name: 'Cat', password: 'password')
      User.second.update(email: 'jerrymouse@gmail.com', first_name: 'Jerry', last_name: 'Mouse', password: 'password')
      User.last.update(email: 'testuser@gmail.com', first_name: 'Test', last_name: 'User', password: 'password')
      Case.first.update(status: 'in_progress')
      Case.second.update(status: 'resolved')
      Case.third.update(status: 'closed')
    end

    def execute
      reset_data
      create_users
    end

    def run
      execute
    end
  end
end
