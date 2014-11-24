class Annotation < ActiveRecord::Base
	belongs_to :image

	attr_accessible :image_id, :x_axis, :y_axis, :details
end
