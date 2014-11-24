class DeviseCreateUsers < ActiveRecord::Migration
  def migrate(direction)
    super
    # Create a default user
    User.create!(email: 'lavinia29@gmail.com', password: 'password2011', password_confirmation: 'password2011', user_type: 'Admin', nickname: 'Administrator', phone_number: 96618963) if direction == :up
  end

  def change
    create_table(:users) do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      # t.string   :reset_password_token
      # t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## Token authenticatable
      t.string :authentication_token

      t.string :nickname
      t.string :phone_number
      t.string :user_type, null: false, default: "User"
      t.string :status, null: false, default: "Created"

      # Mobile Verification
      t.string :verification_code
      t.datetime :verification_sent_at

      # Store the client correlator to be able to query for the sms delivery status later
      # t.string :client_correlator

      # Agency specific attributes
      t.string :address
      t.text :description

      t.timestamps
    end

    add_index :users, :email,                unique: true
    # add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
    add_index :users, :authentication_token, unique: true
    # add_index :users, :phone_number, unique: true
  end
end
