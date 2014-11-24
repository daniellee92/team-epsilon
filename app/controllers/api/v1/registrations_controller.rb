class Api::V1::RegistrationsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :json

  def create

    #if password == password_confirmation

      if request.format != :json
          render :status=>406, :json=>{:message=>"The request must be json"}
          return
      end

      #if email.nil? or password.nil? 
      #  render :status=>400, :json=>{:message=>"The request must contain the user email and password."}
      #  return
      #end

      #user_email=User.find_by_email(email.downcase)
      
      #if user_email != nil
      #  logger.info("User #{email} failed signin, user cannot be found.")
      #  render :status=>401, :json=>{:message=>"Email already exist"}
      #  return
      #end

      @user = User.new(params)
      if @user.save
        @user.ensure_authentication_token
        render :json => {:auth_token=>@user.authentication_token, :email => @user.email}, :status=>201
        return
      else
        warden.custom_failure!
        render :json=> @user.errors, :status=>422
      end

    #else
    #  render :status => 303, :json=>{:message=>"Password does not match"}
    #end
  end

end