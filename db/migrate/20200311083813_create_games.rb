class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
	  t.belongs_to :company, foreign_key: true
	  t.belongs_to :user, foreign_key: true
	  t.belongs_to :team, foreign_key: true
		
	  t.string :state, :password
	  t.boolean :active, default: true
		
	  t.integer :current_turn, :turn1, :turn2
	  t.boolean :rate, default: true
		
	  t.integer :ges_rating
		
	  t.integer :game_seconds, :video_id
	  t.string :youtube_url
	  t.boolean :video_is_pitch
		
	  t.boolean :video_uploading, :video_toggle, :video_upload_start
		
	  t.boolean :replay, default: false
		
      t.timestamps
    end
  end
end
