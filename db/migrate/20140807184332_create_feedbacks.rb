class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.belongs_to :user

      t.string :title
      t.text :details
      t.string :progress_status, null: false, default: "Nil"
      t.string :abuse_status, default: "Nil"
      t.string :delete_status
      t.string :address
      t.float :latitude
      t.float :longitude
      t.datetime :last_acted_at
      t.datetime :datetime_marked_as_resolved
      t.integer :reported_by
      t.string :abuse_reason
      t.integer :handled_by

      t.timestamps
    end
  end
end
