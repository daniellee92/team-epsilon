class NotificationsController < ApplicationController
	before_action :authenticate_user!

	def index
		if current_user.user_type == "User"
			@notifications = Notification.where("user_id = ?", current_user.id).order(created_at: :desc)
		
		elsif current_user.user_type == "Agency"
			# notifications_unassigned_feedbacks = Notification.where("agency_id = ?", 0).order(created_at: :desc)
			# notifications_unassigned_feedbacks.each do |notification|
			# 	feedback = Feedback.find(notification.feedback_id)
			# 	if feedback.handled_by == current_user.id
			# 		notification.update_attribute(:agency_id, feedback.handled_by)
			# 	end
			# end
			@notifications = Notification.where("agency_id = ?", current_user.id).order(created_at: :desc)
		end
	end
end