class Sort

	def self.sort_feedbacks(feedbacks, sort_type)
		if sort_type == "Last Updated"
	      feedbacks = feedbacks.order(last_acted_at: :desc)
	    elsif sort_type == "Last Created"
	      feedbacks = feedbacks.order(created_at: :desc)
	    else

	      if sort_type == "Most Active"
	        fb = sort_by_most_active(feedbacks)
	      elsif sort_type == "Most Commented"
	        fb = sort_by_most_commented(feedbacks)
	      elsif sort_type == "Most Voted"
	        fb = sort_by_most_voted(feedbacks)
	      end
	      
	      fb_sorted = Hash[ fb.sort_by { |feedback, value| value }.reverse ]
	      feedbacks = fb_sorted.keys
	    end
	end


	def self.sort_by_most_active(feedbacks)
	    fb = Hash.new
	    feedbacks.each do |feedback|
	      comments = feedback.comments.count
	      votes = feedback.votes.count
	      activities = comments + votes
	      fb[feedback] = activities
	    end
	    return fb
	end


	def self.sort_by_most_commented(feedbacks)
	    fb = Hash.new
	    feedbacks.each do |feedback|
	      fb[feedback] = feedback.comments.count
	    end
	    return fb
	end
	  
	  
	def self.sort_by_most_voted(feedbacks)
	    fb = Hash.new
	    feedbacks.each do |feedback|
	      fb[feedback] = feedback.votes.count
	    end
	    return fb
	end

end