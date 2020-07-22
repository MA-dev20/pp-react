class AddOptionsToGame < ActiveRecord::Migration[5.2]
  def change
    change_table :games do |t|
      t.boolean :game_sound, default: false
      t.remove :game_seconds, :video_id, :youtube_url, :video_is_pitch, :rating_list_id, :skip_elections, :max_users
    end
  end
end
