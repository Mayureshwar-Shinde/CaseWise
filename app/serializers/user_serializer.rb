class UserSerializer < ActiveModel::Serializer
  attributes :id,
             :first_name,
             :last_name,
             :email,
             :age,
             :date_of_birth,
             :created_at,
             :updated_at
end