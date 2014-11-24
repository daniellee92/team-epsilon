class Api::V2::RegistrationsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, only: :trial_test
  respond_to :json

  def trial_test
  end

  def create
      @user = User.new(params)
      if @user.save
        @user.ensure_authentication_token
        render :status => 200, :json => { :auth_token=>@user.authentication_token }
        return
      else
        warden.custom_failure!
        render :status => 422, :json => @user.errors
      end
  end

end