class CreatePitches < ActiveRecord::Migration[5.2]
  def change
    create_table :pitches do |t|
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
      t.references :user, foreign_key: true
      
      t.timestamps
    end
  end
end
