class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.belongs_to :feedback
      t.integer :user_id
      t.integer :agency_id
      t.string :notification_user
      t.string :notification_agency

      t.timestamps
    end
  end
end
