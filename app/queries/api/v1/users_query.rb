module Api
  module V1
    class UsersQuery
      def initialize(params)
        @params = params
      end

      def call
        users = User.all
        users = users.where(first_name: @params[:first_name]) if @params[:first_name].present?
        users = users.where(last_name: @params[:last_name]) if @params[:last_name].present?
        users = users.where(email: @params[:email]) if @params[:email].present?
        users
      end
    end
  end
end