class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session#, if: Proc.new { |c| c.request.format == 'application/json' }

  before_filter :suspended?
  before_filter :deleted?
  before_filter :store_location
  before_filter :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_user

  # skip_before_action :verify_authenticity_token, if: :json_request?

  # This is our new function that comes before Devise's one
  #before_filter :authenticate_user_from_token!

  # This is Devise's authentication
  #before_filter :authenticate_user!
 
  #private
  
  # For this example, we are simply using token authentication
  # via parameters. However, anyone could use Rails's token
  # authentication features to get the token from a header.
  def authenticate_user_from_token!
    user_token = params[:user_token].presence
    user       = user_token && User.find_by_authentication_token(user_token.to_s)
 
    if user
      # Notice we are passing store false, so the user is not
      # actually stored in the session and a token is needed
      # for every request. If you want the token to work as a
      # sign in token, you can simply remove store: false.
      sign_in user, store: false
    end
  end

  #Get the current signed in user
  def current_user=(user)
    @current_user = user
  end

  # def verify_authenticity_token
  #   @current_user = User.find_by_authentication_token(params[:auth_token])
  #   render status: 401, json: { :message => "Invalid token." } and return unless @current_user
  # end

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get? 
    if (request.path != "/users/sign_in" &&
        request.path != "/users/sign_up" &&
        request.path != "/users/password/new" &&
        request.path != "/users/password/edit" &&
        request.path != "/users/confirmation" &&
        request.path != "/users/sign_out" &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath 
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  def authorize_admin!
    if current_user.user_type != "Admin"
      flash[:error] = "Unauthorized Access"
      redirect_to root_path
    end
  end

  def suspended?
    if current_user.present? && current_user.status == "Suspended"
      email = current_user.email
      sign_out current_user
      flash[:notice] = "This account (" + email + ") has been suspended."
      root_path
    end
  end

  def deleted?
    if current_user.present? && current_user.status == "Deleted"
      email = current_user.email
      sign_out current_user
      flash[:notice] = "This account (" + email + ") has been deleted."
      root_path
    end
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :nickname
    devise_parameter_sanitizer.for(:sign_up) << :phone_number
    devise_parameter_sanitizer.for(:sign_up) << :user_type
  end

  # def json_request?
  #   request.format.json?
  # end

end
