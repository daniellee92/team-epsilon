class CreateAnnotations < ActiveRecord::Migration
  def change
    create_table :annotations do |t|
      t.belongs_to :image
      t.float :x_axis
      t.float :y_axis
      t.string :details

      t.timestamps
    end
  end
end
