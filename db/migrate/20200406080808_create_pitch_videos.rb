class CreatePitchVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :pitch_videos do |t|
	  t.belongs_to :game_turn, foreign_key: true
	  t.belongs_to :user, foreign_key: true
	  t.string :video
	  t.integer :duration
	  t.boolean :favorite, default: false
	  t.boolean :released, default: false
		
	  t.string :video_text
	  t.integer :words_count, default: 0
	  t.integer :do_words, default: 0
	  t.integer :dont_words, default: 0

      t.timestamps
    end
  end
end
