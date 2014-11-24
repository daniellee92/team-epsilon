class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.belongs_to :feedback
      t.belongs_to :user   	

      t.timestamps
    end
  end
end
