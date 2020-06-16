class CreatePitches < ActiveRecord::Migration[5.2]
  def change
    create_table :pitches do |t|
	  t.belongs_to :company, foreign_key: true
	  t.belongs_to :department, foreign_key: true
	  t.belongs_to :team, foreign_key: true
	  t.belongs_to :user, foreign_key: true
      t.string :title
      t.text :description
      t.boolean :pitch_sound, default: true
      t.string :show_ratings, default: "all"
      t.text :video_path
      t.boolean :skip_elections, default: false
      t.string :video
      t.string :image
      t.boolean :destroy_video, default: false
      t.boolean :destroy_image, default: false
      
      t.timestamps
    end
  end
end
