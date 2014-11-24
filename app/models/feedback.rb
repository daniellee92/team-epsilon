class Feedback < ActiveRecord::Base
	belongs_to :user

	has_many :comments
	has_many :votes
	has_many :notifications
	has_many :images, dependent: :destroy

	attr_accessible :title, :details, :status, :address, :latitude, :longitude, :last_acted_at, :reported_by, :abuse_reason, :abuse_status, :user_id, :created_at
	# geocoded_by :address
	# after_validation :geocode, :if => :address_changed?
	
	# reverse_geocoded_by :latitude, :longitude
	# after_validation :reverse_geocode, :if => :address_changed?

	def timestamp
  		created_at.strftime('%d %B %Y %H:%M:%S')
	end
	
end
