class Notification < ActiveRecord::Base
	belongs_to :feedback

	attr_accessible :feedback_id, :user_id, :agency_id, :notification_user, :notification_agency, :created_at
end
