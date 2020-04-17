class CreateVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :videos do |t|
	  t.belongs_to :user, foreign_key: true
	  t.belongs_to :company, foreign_key: true
	  t.belongs_to :department, foreign_key: true
	  t.string :video
	  t.integer :duration
	  t.string :name
      t.timestamps
    end
  end
end
