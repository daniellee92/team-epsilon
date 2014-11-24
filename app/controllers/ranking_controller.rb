class RankingController < ApplicationController
	def index
		if params[:sort_type] == "Total Activity"
			users = users_sort_by_activities
		
		elsif params[:sort_type] == "#Feedbacks"
			users = users_sort_by_feedbacks

		elsif params[:sort_type] == "#Comments"
			users = users_sort_by_comments

		elsif params[:sort_type] == "#Votes"
			users = users_sort_by_votes
		end

		@sort_type = params[:sort_type]
		@users = users.sort_by { |user, value| value }.reverse
	end

	private

	def get_users
		all_users = User.where("status != ? and user_type = ?", "Deleted", "User")
	end

	def users_sort_by_activities
		all_users = get_users
		users = Hash.new
		all_users.each do |user|
			feedbacks = user.feedbacks.count 
            comments = user.comments.count
            votes = user.votes.count
            activities = feedbacks + comments + votes
			users[user] = activities
		end
		return users
	end

	def users_sort_by_feedbacks
		all_users = get_users
		users = Hash.new
		all_users.each do |user|
			users[user] = user.feedbacks.count
		end
		return users
	end

	def users_sort_by_comments
		all_users = get_users
		users = Hash.new
		all_users.each do |user|
			users[user] = user.comments.count
		end
		return users
	end

	def users_sort_by_votes
		all_users = get_users
		users = Hash.new
		all_users.each do |user|
			users[user] = user.votes.count
		end
		return users
	end
end