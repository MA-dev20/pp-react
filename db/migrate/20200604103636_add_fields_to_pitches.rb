class AddFieldsToPitches < ActiveRecord::Migration[5.2]
  def change
    add_column :pitches, :pitch_sound, :boolean, default: true
    add_column :pitches, :show_ratings, :string, default: "all"
    add_column :pitches, :video_path, :text
    add_column :pitches, :skip_elections, :boolean, default: false
    add_column :pitches, :video, :string
    add_column :pitches, :image, :string
  end
end
