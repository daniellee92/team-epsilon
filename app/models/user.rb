class User < ActiveRecord::Base
  has_many :feedbacks
  has_many :comments
  has_many :votes
  # has_many :notifications


  before_save :ensure_authentication_token

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :recoverable, :confirmable
  devise :database_authenticatable, :registerable,
         :rememberable, :trackable, :validatable, :token_authenticatable,
         :omniauthable

  attr_accessible :email, :password, :password_confirmation, :authentication_token,
                :remember_me, :nickname, :phone_number, :user_type, :status, :description

  def ensure_authentication_token
    self.authentication_token ||= generate_authentication_token
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    if user
      return user
    else
      registered_user = User.where(:email => auth.info.email).first
      if registered_user
        return registered_user
      else
        user = User.create(name:auth.extra.raw_info.name,
                           provider:auth.provider,
                           uid:auth.uid,
                           email:auth.info.email,
                           password:Devise.friendly_token[0,20],
        )
      end    end
  end
  
end
