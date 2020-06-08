class AddFieldsToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :video_id, :string
    add_column :tasks, :audio_id, :string
    add_column :tasks, :media_option, :string, default: 'catchword'
    add_column :tasks, :destroy_media, :string
  end
end
