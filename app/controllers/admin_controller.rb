class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  helper_method :sort_column_feedback, :sort_column_user, :sort_direction

  @@page_size = 20

  # ---------- Feedback Index Methods ----------
  
  def feedback_index
    @feedbacks = Feedback.where("delete_status is null").order(sort_column_feedback + " " + sort_direction).paginate(:page => params[:page], :per_page => @@page_size)
    @agencies = User.where("user_type = ?", "Agency").where.not(status: "Deleted")
  end

  def assign_agency
    @feedback = Feedback.find(params[:feedback_id])
    prev_agency = @feedback.handled_by
    @feedback.handled_by = params[:user][:user_id]
    @feedback.progress_status = "In Progress"
    @feedback.last_acted_at = Time.zone.now

    if @feedback.save!
        # Create Notification
        agency = User.find(@feedback.handled_by)
        notification_agency = "Feedback #" + @feedback.id.to_s + " has been assigned to you."

        if prev_agency.blank?
          notification_user = "Feedback #" + @feedback.id.to_s + " has been assigned to " + agency.nickname + "."
          Notification.create(feedback_id: @feedback.id, user_id: @feedback.user_id, agency_id: agency.id, notification_user: notification_user, notification_agency: notification_agency)
        else
          notification_user = "Feedback #" + @feedback.id.to_s + " has been reassigned to " + agency.nickname + "."
          Notification.create(feedback_id: @feedback.id, user_id: @feedback.user_id, agency_id: agency.id, notification_user: notification_user, notification_agency: notification_agency)
          Notification.create(feedback_id: @feedback.id, agency_id: prev_agency, notification_agency: notification_user)
        end

        redirect_to({:action => "feedback_index"}, notice: 'Agency has been successfully assigned to feedback.')
    else
        render :feedbackIndex, notice: "Agency has failed to be assigned to feedback."
    end
  end

  def delete_feedback
    feedback = Feedback.find(params[:id])
    feedback.update_attribute(:delete_status, "Deleted")

    # Create Notification
    notification_user = "Feedback #" + feedback.id.to_s + " has been deleted by the administrator."
    agency_id = feedback.handled_by
    Notification.create(feedback_id: feedback.id, user_id: feedback.user_id, agency_id: agency_id, notification_user: notification_user, notification_agency: notification_user)
        
    redirect_to({:action => "feedback_index"}, notice: 'Feedback #' + feedback.id.to_s + ' has been successfully deleted.')
  end

  def assign_abuse_status
    feedback = Feedback.find(params[:feedback_id])
    feedback.update_attribute(:abuse_status, params[:abuse_status_new])

    # Create Notification
    notification_user = "Feedback #" + feedback.id.to_s + " has been deemed as " + feedback.abuse_status.downcase + " by the administrator."
    agency_id = feedback.handled_by
    Notification.create(feedback_id: feedback.id, user_id: feedback.user_id, agency_id: agency_id, notification_user: notification_user, notification_agency: notification_user)
    
    redirect_to({ :controller => "feedbacks", :action => "show", :feedback_id => feedback.id })
  end

  # ---------- User Index Methods ----------

  def user_index
  	@users = User.where("user_type = ?", "User").where.not(status: "Deleted").order(sort_column_user + " " + sort_direction).paginate(:page => params[:page], :per_page => @@page_size)
  end

  def delete_user
    user = User.find(params[:id])
    user.update_attribute(:status, "Deleted")
    if user.user_type == "User"
      redirect_to({:action => "user_index"}, notice: 'User, ' + user.nickname + ' has been successfully deleted.')
    else 
      redirect_to({:action => "agency_index"}, notice: 'Agency ' + user.nickname + ' has been successfully deleted.')
    end
  end

  def suspend_user
    user = User.find(params[:id])
    user.update_attribute(:status, "Suspended")
    redirect_to({:action => "user_index"}, notice: 'User, ' + user.nickname + ' has been suspended.')
  end

  def unsuspend_user
    user = User.find(params[:id])
    user.update_attribute(:status, "Unsuspended")
    redirect_to({:action => "user_index"}, notice: 'User, ' + user.nickname + ' has been unsuspended.')
  end

  # ---------- Agency Index Methods ----------

  def agency_index
  	@agencies = User.where("user_type = ?", "Agency").where.not(status: "Deleted").order(sort_column_user + " " + sort_direction)
  end

  def add_agency
    user = User.find_by_email(params[:email])
    if user == nil
      agency = User.create(email: params[:email], nickname: params[:nickname], description: params[:description], password: 'password', password_confirmation: 'password', user_type: 'Agency')
      if agency.save
      redirect_to({action: "agency_index"}, notice: 'Agency, ' + params[:nickname] + ', has been successfully added.')
    end
    else
      flash.alert = "Account with the email, " + params[:email] + ", already exists."
    end
  end

  # ---------- Developer Index ----------

  def image_index
    @images = Image.all.order(created_at: :asc)
  end

  def notification_index
    @notifications = Notification.all.order(created_at: :desc)
  end

  def user_agency_index
    @users_agencies = User.all.order(sort_column_user + " " + sort_direction)
  end

  def annotation_index
    @annotations = Annotation.all.order(created_at: :asc)
  end

  # ---------- Private Methods ----------

  private
  
  def sort_column_feedback
    Feedback.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def sort_column_user
    User.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end