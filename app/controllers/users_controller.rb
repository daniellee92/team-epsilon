class UsersController < ApplicationController
	def index
		@users = User.all
	end

	def create
		User.create(user_params)
	end
	
	private
	def user_params
		params.require(:user).permit(:nickname, :provider, :uid, :email)
	end
end
