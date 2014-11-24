class Comment < ActiveRecord::Base
	belongs_to :feedback
	belongs_to :user

	attr_accessible :feedback_id, :user_id, :details
end
