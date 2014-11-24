class FeedbacksController < ApplicationController

  before_action :authenticate_user!, except: [:index, :show, :search, :other]

  @@page_size = 5

  # GET /feedbacks
  # GET /feedbacks.json
  def index
    @page_title = "All Feedbacks"
    @sort_type = set_sort_type
    @feedbacks = Sort.sort_feedbacks(get_all_feedbacks, @sort_type).paginate(:page => params[:page], :per_page => @@page_size)
  end


  def my_feedbacks
    @page_title = "My Feedbacks"    
    @sort_type = set_sort_type
    @feedbacks = Sort.sort_feedbacks(get_my_feedbacks, @sort_type).paginate(:page => params[:page], :per_page => @@page_size)
    render :template => "feedbacks/index.html.erb"
  end


  def search
    if params[:page_title] == "My Feedbacks" or params[:page_title] == "Search Result (My Feedbacks)"
      feedbacks = get_my_feedbacks
      search_type = "My"
    elsif params[:page_title] == "All Feedbacks" or params[:page_title] == "Search Result (All Feedbacks)"
      feedbacks = get_all_feedbacks
      search_type = "All"
    else
      feedbacks = get_other_feedbacks
      other_user = User.find(session[:other_user_id])
      search_type = other_user.nickname + "'s"
    end

    @page_title = "Search Result (" + search_type + " Feedbacks)"
    
    if !params[:search].blank?
      @query = params[:search]
    elsif !session[:search].blank?
      @query = session[:search]
    end
    session[:search] = @query

    search_results = feedbacks.where("lower(title) LIKE ? or lower(details) LIKE ? or lower(address) LIKE ?", "%#{@query}%".downcase, "%#{@query}%".downcase, "%#{@query}%".downcase)
    @sort_type = set_sort_type
    @feedbacks = Sort.sort_feedbacks(search_results, @sort_type).paginate(:page => params[:page], :per_page => @@page_size)
    render :template => "feedbacks/index.html.erb"
  end


  def other
    other_user = User.find(set_other_user_id)
    @page_title = "Feedbacks By " + other_user.nickname
    @sort_type = set_sort_type
    @feedbacks = Sort.sort_feedbacks(get_other_feedbacks, @sort_type).paginate(:page => params[:page], :per_page => @@page_size)
    render :template => "feedbacks/index.html.erb"
  end


  def get_all_feedbacks
    if !current_user.blank? and current_user.user_type == "Admin"
      feedbacks = Feedback.where("delete_status is null")
    else
      feedbacks = Feedback.where("delete_status is null").where("abuse_status = ? or abuse_status = ?", "Nil", "Not Abusive")
    end
    return feedbacks
  end


  def get_my_feedbacks
    fb = Feedback.where("delete_status is null").where("abuse_status = ? or abuse_status = ?", "Nil", "Not Abusive")
    if current_user.user_type == "User"
      feedbacks = fb.where("user_id = ?", current_user.id)
    elsif current_user.user_type == "Agency"
      feedbacks = fb.where("handled_by = ?", current_user.id)
    end
    return feedbacks
  end


  def get_other_feedbacks
    feedbacks = get_all_feedbacks.where("user_id = ?", session[:other_user_id])
    return feedbacks
  end


  def set_sort_type
    sort_type = "Last Updated"
    if !params[:sort_type].blank?
      sort_type = params[:sort_type]
    elsif !session[:sort_type].blank?
      sort_type = session[:sort_type]
    end
    session[:sort_type] = sort_type
    return sort_type
  end


  def set_other_user_id
    if !params[:other_user_id].blank?
      other_user_id = params[:other_user_id]
    elsif !session[:other_user_id].blank?
      other_user_id = session[:other_user_id]
    end
    session[:other_user_id] = other_user_id
    return other_user_id
  end


  # GET /feedbacks/1
  # GET /feedbacks/1.json
  def show
    @feedback = Feedback.find(params[:feedback_id])
    @nickname = User.find(@feedback.user_id).nickname
    #display the location of the issue on google map
    @hash = Gmaps4rails.build_markers(@feedback) do |user, marker|
      marker.lat user.latitude
      marker.lng user.longitude
      marker.infowindow user.title
    end
  end


  def create_comment
    feedback = Feedback.find(params[:feedback_id])
    comment = Comment.new
    comment.feedback_id = feedback.id
    comment.user_id = current_user.id
    comment.details = params[:details]

    respond_to do |format|
      if comment.save!
        feedback.update_attribute(:last_acted_at, Time.zone.now)

        # Create Notification
        if current_user.id != feedback.user_id
          notification_user = "Feedback #" + feedback.id.to_s + " has been commented on by " + current_user.nickname + "."
          Notification.create(feedback_id: feedback.id, user_id: feedback.user_id, notification_user: notification_user)
        end
        
        format.html { redirect_to({ :action => "show", :feedback_id => feedback.id }) }
        format.json { render status: 201, json: { :message => 'Comment created.' } }
      else
        format.html { redirect_to({ :action => "show", :feedback_id => feedback.id, notice: 'Comment has failed.' }) }
        format.json { render json: { :error => comment.errors } }
      end
    end
  end


  def create_vote
    feedback = Feedback.find(params[:feedback_id])
    vote = Vote.new
    vote.feedback_id = feedback.id
    vote.user_id = current_user.id

    respond_to do |format|
      if vote.save!
        feedback.update_attribute(:last_acted_at, Time.zone.now)
        format.html { redirect_to({ :action => "show", :feedback_id => feedback.id }) }
        format.json { render status: 201, json: { :message => 'Vote created.' } }
      else
        format.html { redirect_to({ :action => "show", :feedback_id => feedback.id, notice: 'Vote has failed.' }) }
        format.json { render json: { :error => vote.errors } }
      end
    end
  end

  def unvote
    Vote.find(params[:vote_id]).destroy
    redirect_to({ :action => "show", :feedback_id => params[:feedback_id] })
  end

  def report_abuse
    feedback = Feedback.find(params[:feedback_id])
    feedback.update_attribute(:abuse_status, "Reported")
    if !params[:abuse_reason].blank?
      feedback.update_attribute(:abuse_reason, params[:abuse_reason])
    end
    feedback.update_attribute(:last_acted_at, Time.zone.now)

    # Create Notification
    notification_user = "Feedback #" + feedback.id.to_s + " has been reported as abusive by " + current_user.nickname + "."
    agency_id = feedback.handled_by
    Notification.create(feedback_id: feedback.id, user_id: feedback.user_id, agency_id: agency_id, notification_user: notification_user, notification_agency: notification_user)
    
    respond_to do |format|
      format.html { redirect_to({ :action => "index" }, notice: 'Feedback has been reported as abusive and, hidden. The administrator will review this feedback.') }
      format.json { render status: 200, json: { :message => 'Feedback reported.' } }
    end
  end

  def assign_progress_status
    feedback = Feedback.find(params[:feedback_id])
    if params[:progress_status_new] != ""
      feedback.update_attribute(:progress_status, params[:progress_status_new])
    end

    # Create Notification
    progress = params[:progress_status_new]
    agency = User.find(feedback.handled_by)
    if progress == "Resolved"
      notification_user = "Feedback #" + feedback.id.to_s + " has been resolved by " + agency.nickname + ". (Verified by: " + current_user.nickname + ")"
      notification_agency = notification_user
    else
      notification_user = "Feedback #" + feedback.id.to_s + " is still unresolved. (Verified by: " + current_user.nickname + ") It will be reviewed by " + agency.nickname + "."
      notification_agency = "Feedback #" + feedback.id.to_s + " is still unresolved. (Verified by: " + current_user.nickname + ") Please review this feedback."
    end

    if current_user.user_type == "Admin"
      Notification.create(feedback_id: feedback.id, user_id: feedback.user_id, agency_id: feedback.handled_by, notification_user: notification_user, notification_agency: notification_agency)
    else
      Notification.create(feedback_id: feedback.id, agency_id: feedback.handled_by, notification_agency: notification_agency)
    end

    respond_to do |format|
      format.html { redirect_to({ :controller => "feedbacks", :action => "show", :feedback_id => feedback.id }) }
      format.json { render status: 200, json: { :message => 'Progress status assigned.' } }
    end
  end

  # ---------- Agency Methods Start ----------

  def marked_as_resolved
    feedback = Feedback.find(params[:feedback_id])
    feedback.update_attribute(:progress_status, "Marked As Resolved")
    current_datetime = Time.zone.now
    feedback.update_attribute(:datetime_marked_as_resolved, current_datetime)
    feedback.update_attribute(:last_acted_at, current_datetime)

    # Create Notification
    agency = User.find(feedback.handled_by)
    notification_user = "Feedback #" + feedback.id.to_s + " has been marked as resolved by " + agency.nickname + ". Please verify if it has really been resolved."
    Notification.create(feedback_id: feedback.id, user_id: feedback.user_id, notification_user: notification_user)

    redirect_to({ :action => "show", :feedback_id => feedback.id })
  end

  # ---------- Agency Methods End ----------

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def feedback_params
      params.require(:feedback).permit(:title, :details, :address, :latitude, :longitude)
    end
end