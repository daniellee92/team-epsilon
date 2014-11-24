class Api::V2::NotificationsController < NotificationsController
skip_before_action :verify_authenticity_token
before_action :authenticate_user!, only: :trial_test
respond_to :json

	def trial_test
	end

	def get_new_notifications
		@current_user = User.find_by_authentication_token(params[:auth_token])
    	render status: 401, json: { :error => "Invalid token." } and return unless @current_user
		notifications = Notification.where("user_id = ?", @current_user.id).order(created_at: :desc).where("id > ?", params[:newest_notification_id])
		render status: 200, json: { :notifications => notifications } 
	end

	def get_more_notifications
		@current_user = User.find_by_authentication_token(params[:auth_token])
    	render status: 401, json: { :error => "Invalid token." } and return unless @current_user

    	size = 2
    	if params[:oldest_notification_id] == "0"
    		notifications = Notification.where("user_id = ?", @current_user.id).order(created_at: :desc).limit(size)
    	else
    		notifications = Notification.where("user_id = ?", @current_user.id).order(created_at: :desc).where("id < ?", params[:oldest_notification_id]).limit(size)
    	end
    	render status: 200, json: { :notifications => notifications } 
	end
end