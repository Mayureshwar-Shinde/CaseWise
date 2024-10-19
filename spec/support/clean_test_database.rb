def reset_data
  Case.delete_all
  User.delete_all
end