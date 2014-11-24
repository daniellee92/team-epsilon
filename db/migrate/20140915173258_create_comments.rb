class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.belongs_to :feedback
      t.belongs_to :user
      t.text :details
      t.binary :image

      t.timestamps
    end
  end
end
