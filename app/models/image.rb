class Image < ActiveRecord::Base
	belongs_to :feedback
	has_many :annotations, dependent: :destroy

	attr_accessible :feedback_id, :image_data
end
