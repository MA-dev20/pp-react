class CreateTaskMedia < ActiveRecord::Migration[5.2]
  def change
    create_table :task_media do |t|
      t.string :audio
      t.string :video
      
      t.timestamps
    end
  end
end
