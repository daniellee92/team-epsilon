class VerificationsController < ApplicationController
  before_action :authenticate_user!

  @@validity_duration = 5 # in minutes
  
  def new
    @phone_number = current_user.phone_number
    @nickname = current_user.nickname
  end

  def create
    # current_user = User.last
    @phone_number = current_user.phone_number
    @nickname = current_user.nickname
  	verification_code = rand(10**6).to_s

  	sms_client = OneApi::SmsClient.new('smuadmin2', 'smuadmin2')
    sms = OneApi::SMSRequest.new
    sms.sender_address = 'Epsilon'
    sms.address = '65' + @phone_number

    sms.message = 'Hi ' + @nickname + ", please use the OTP: " + verification_code + " to complete your account registration. This passcode will expire in " + @@validity_duration.to_s + " minutes."
    sms.callback_data = 'Any string'

    result = sms_client.send_sms(sms)

    # Store the client correlator to be able to query for the sms delivery status later
    client_correlator = result.client_correlator

    current_user.update_attribute(:verification_code, verification_code)
    current_user.update_attribute(:verification_sent_at, Time.zone.now)
    # current_user.update_attribute(:client_correlator, client_correlator)

    # Possible statuses are: DeliveredToTerminal, DeliveryUncertain, DeliveryImpossible, MessageWaiting, DeliveredToNetwork
    @delivery_status = sms_client.query_delivery_status(client_correlator)
  end

  def verify
    # current_user = User.last
    @phone_number = current_user.phone_number
    @nickname = current_user.nickname

    if current_user.status == "Created"
    	if params[:verification_code_user] == current_user.verification_code
    		verification_expire_at = current_user.verification_sent_at + @@validity_duration.minutes
    		verified_at = Time.zone.now
    		
        if verified_at <= verification_expire_at
  	  		current_user.update_attribute(:status, "Verified")
  	  		@verification_message = "Verified."
  	  	else
  	  		@verification_message = "Verification code has expired."
  	  	end

    	else
    		@verification_message = "Verification failed."
    	end

    else
      @verification_message = "Already verified."
    end

    if current_user.status == "Verified" 
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { render status: 200, json: { :verification_message => @verification_message } }
      end
    else
      respond_to do |format|
        format.html {  }
        format.json { render status: 200, json: { :verification_message => @verification_message } }
      end
    end
  end

end
