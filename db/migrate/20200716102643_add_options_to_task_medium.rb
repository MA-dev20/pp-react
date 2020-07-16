class AddOptionsToTaskMedium < ActiveRecord::Migration[5.2]
  def change
    add_column :task_media, :video_url_id, :string
    add_column :task_media, :video_url_type, :string
    add_column :task_media, :video_img, :string
    add_column :task_media, :video_title, :string
  end
end
