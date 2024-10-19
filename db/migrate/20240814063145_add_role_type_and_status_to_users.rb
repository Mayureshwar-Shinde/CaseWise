class AddRoleTypeAndStatusToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :role_type, :integer, default: 1
    add_column :users, :status, :integer, default: 0
  end
end
