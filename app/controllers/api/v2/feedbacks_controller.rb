class Api::V2::FeedbacksController < FeedbacksController
skip_before_action :verify_authenticity_token
before_action :authenticate_user!, only: :trial_test
respond_to :json

	def trial_test
	end

	def display_all
		retrieve_before_time_dt = DateTime.strptime(params[:retrieve_before_time], '%Y-%m-%d %H:%M:%S')
	    feedbacks = Feedback.where("delete_status is null").where("abuse_status = ? or abuse_status = ?", "Nil", "Not Abusive").order(last_acted_at: :desc).where("last_acted_at < ?", retrieve_before_time_dt).limit(3)
	    
	    feedbacks_data = []

	    feedbacks.each do |feedback|
	    	feedback_data = Hash.new
	    	feedback_data["feedback"] = feedback
	    	feedback_data["total_votes"] = feedback.votes.count
	    	feedback_data["total_comments"] = feedback.comments.count

	    	images = feedback.images
	    	if images.size > 0
	    		image = images.first
	    		feedback_data["image"] = image
	    		feedback_data["annotations"] = image.annotations
	    	end
	    	
	    	feedbacks_data << feedback_data
	    end

		render json: { :feedbacks_data => feedbacks_data }
	end

	def display_mine
		retrieve_before_time_dt = DateTime.strptime(params[:retrieve_before_time], '%Y-%m-%d %H:%M:%S')
	    fb = Feedback.where("delete_status is null").where("abuse_status = ? or abuse_status = ?", "Nil", "Not Abusive").order(last_acted_at: :desc).where("last_acted_at < ?", retrieve_before_time_dt).limit(3)
	    if current_user.user_type == "User"
	      feedbacks = fb.where("user_id = ?", current_user.id)
	    elsif current_user.user_type == "Agency"
	      feedbacks = fb.where("handled_by = ?", current_user.id)
	    end

	    feedbacks_data = []

	    feedbacks.each do |feedback|
	    	feedback_data = Hash.new
	    	feedback_data["feedback"] = feedback
	    	feedback_data["total_votes"] = feedback.votes.count
	    	feedback_data["total_comments"] = feedback.comments.count

	    	images = feedback.images
	    	if images.size > 0
	    		image = images.first
	    		feedback_data["image"] = image
	    		feedback_data["annotations"] = image.annotations
	    	end
	    	
	    	feedbacks_data << feedback_data
	    end

		render json: { :feedbacks_data => feedbacks_data }
	end

	def display_details
		feedback = Feedback.find(params[:feedback_id])
		nickname = User.find(feedback.user_id).nickname
		total_votes = feedback.votes.count
		total_comments = feedback.comments.count

		images = feedback.images
		images_annotations = Hash.new
    	if images.size > 0
    		count = 0
    		images.each do |image|
    			key = "image_annotations_" + count.to_s
	    		image_annotations = Hash.new
	    		image_annotations["image"] = image
    			image_annotations["annotations"] = image.annotations

	    		images_annotations[key] = image_annotations
	    		count += 1
	    	end
    	end

		render json: { :feedback => feedback, :nickname => nickname, :total_votes => total_votes, :total_comments => total_comments, :images_annotations => images_annotations }
	end

	def create
		@current_user = User.find_by_authentication_token(params[:auth_token])
    	render status: 401, json: { :error => "Invalid token." } and return unless @current_user

    	@feedback = Feedback.new(feedback_params)
    	
		if @feedback.save
			@feedback.update_attribute(:last_acted_at, Time.zone.now)
			@feedback.update_attribute(:user_id, @current_user.id)
			no_of_images = 0
			no_of_annotations = 0

			# Create image models if any
			# params[:images_annotations] has the following structure: image$x_axis^y_axis^details$x_axis^y_axis^details | image
			if !params[:images_annotations].blank?
				images_annotations = params[:images_annotations].split("|")
				no_of_images = images_annotations.size

				images_annotations.each do |image_annotation|
					annotations = image_annotation.split("$")
					image_data = annotations.shift
					image = Image.new
					image.feedback_id = @feedback.id
					image.image_data = image_data

					if image.save!
						
						# Create annotation models if any
						if annotations.size > 0
							no_of_annotations += annotations.size
							
							annotations.each do |a|
								annotation_values = a.split("^")
								annotation = Annotation.new
								annotation.image_id = image.id
								annotation.x_axis = annotation_values.at(0)
								annotation.y_axis = annotation_values.at(1)
								annotation.details = annotation_values.at(2)
								
								if !annotation.save!
									@feedback.destroy
									render status: 422, json: { :error => "Failed to create feedback. Unable to save annotation(s)." }
								end
							end
						end
					else
						@feedback.destroy
						render status: 422, json: { :error => "Failed to create feedback. Unable to save image(s)." }
					end
				end
			end

			render status: 201, json: { :message => "Feedback created with " + no_of_images.to_s + " images and " + no_of_annotations.to_s + " annotations." }
		else
			render status: 422, json: { :error => "Failed to create feedback." }
		end
	end

	def create_comment
		@current_user = User.find_by_authentication_token(params[:auth_token])
    	render status: 401, json: { :error => "Invalid token." } and return unless @current_user
    	super
	end

	def create_vote
		@current_user = User.find_by_authentication_token(params[:auth_token])
    	render status: 401, json: { :error => "Invalid token." } and return unless @current_user
    	super
	end

	def get_vote
		@current_user = User.find_by_authentication_token(params[:auth_token])
    	render status: 401, json: { :error => "Invalid token." } and return unless @current_user
    	vote = Vote.where("user_id = ? AND feedback_id = ?", @current_user.id, params[:feedback_id]).take
    	return vote
    end

    def check_vote
    	if get_vote.blank?
    		render status: 200, json: { :message => "Not voted" }
    	else
    		render status: 200, json: { :message => "Voted" }
    	end
    end

	def unvote
		get_vote.destroy
		render status: 200, json: { :message => "Vote destroyed." }
	end

	def get_comments
		feedback = Feedback.find(params[:feedback_id])
		comments = feedback.comments
		comments_nicknames = []
		if !comments.blank?
			comments.each do |comment|
				nickname = User.find(comment.user_id).nickname
				comment_nickname = { "comment" => comment, "nickname" => nickname }
				comments_nicknames << comment_nickname
			end
		end
		render status: 200, json: { :comments_nicknames => comments_nicknames } 
	end

	def report_abuse
		@current_user = User.find_by_authentication_token(params[:auth_token])
    	render status: 401, json: { :error => "Invalid token." } and return unless @current_user
    	super
	end

	def assign_progress_status
		if params[:progress_status_new] == "In Progress" or params[:progress_status_new] == "Resolved"
			super
		else
			render status: 401, json: { :error => "Invalid progress status. progress_status_new can only be In Progress or Resolved" }
		end
	end

	private
		def feedback_params
		    params.permit(:title, :details, :address, :latitude, :longitude)
			# require(:feedback)
	    end
end
