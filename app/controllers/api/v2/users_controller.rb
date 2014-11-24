class Api::V2::UsersController < UsersController
	skip_before_action :verify_authenticity_token
	before_action :authenticate_user!, only: :trial_test
	respond_to :json

	def trial_test
  	end

	def email_exists
		render :json => { :email_exists => User.exists?(:email => params[:user_email]) }
	end

	def facebook_login
		user = User.find_by_email(params[:user_email])
		if user != nil
			render :json => { :auth_token => user.authentication_token }
		else
			render status: 401, :json => { :error => "Invalid email." }
		end
	end

	def get_user
		user = User.find_by_authentication_token(params[:auth_token])
		if user != nil
			created_at = user.created_at.strftime("%Y-%m-%d %H:%M:%S")
			render :json => { :user => user, :created_at => created_at }
		else
			render status: 401, json: { :error => "Invalid token." } 
		end
	end

	def change_password
		@current_user = User.find_by_authentication_token(params[:auth_token])
		render status: 401, json: { :error => "Invalid token." } and return unless @current_user

		if @current_user.valid_password?(params[:password])
			@current_user.update_attribute(:password, params[:new_password])
			render status: 200, :json => { :message => "Changed password." }
		else
			render status: 200, :json => { :error => "Incorrect password." }
		end
		
	end

	def get_agency
		agency = User.find(params[:agency_id])
		if agency != nil
			render status: 200, :json => { :agency => agency }
		else
			render status: 401, :json => { :error => "Invalid ID." }
		end
	end
end