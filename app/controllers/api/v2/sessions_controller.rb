class Api::V2::SessionsController < Devise::SessionsController 
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, only: :trial_test
  respond_to :json

  # === References ===
  # http://stackoverflow.com/questions/20982295/ruby-on-rails-devise-mobile-api
  # http://dev.fruitbyte.com/?p=29
  # http://stackoverflow.com/questions/16901023/rails-api-gem-and-devise-token-authentication

  def trial_test
  end
 
  def create
    resource = User.find_for_database_authentication(:email => params[:email])
    return invalid_login_attempt unless resource
    resource.ensure_authentication_token

    if resource.valid_password?(params[:password])
      if resource.status == "Suspended"
        render :status => 200, :json => { :error => "This user has been suspended." }
      elsif resource.status == "Deleted"
        render :status => 200, :json => { :error => "This user has been deleted." } 
      else
        render :status => 200, :json => { :auth_token => resource.authentication_token }
      end
    else
      invalid_login_attempt
    end
  end

  def destroy
    @current_user = User.find_by_authentication_token(params[:auth_token])
    render status: 401, json: { :error => "Invalid token." } and return unless @current_user
    @current_user.reset_authentication_token!
    render :json => { :message => "Auth_token has been reset." }
  end
 
  def invalid_login_attempt
    render status: 401, :json => { :error => "Login failed. Incorrect email or password." }
  end

end  

