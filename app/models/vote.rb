class Vote < ActiveRecord::Base
	belongs_to :feedback
	belongs_to :user
end
