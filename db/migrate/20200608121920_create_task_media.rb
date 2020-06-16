class CreateTaskMedia < ActiveRecord::Migration[5.2]
  def change
    create_table :task_media do |t|
      t.string :audio
      t.string :video
      t.string :pdf
	  t.string :image
	  t.integer :duration
	  t.string :media_type
      t.timestamps
    end
  end
end
