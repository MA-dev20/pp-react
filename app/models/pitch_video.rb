class PitchVideo < ApplicationRecord
  belongs_to :game_turn
  belongs_to :user
  
  mount_uploader :video, PitchUploader
	
  after_create do
	self.duration = FFMPEG::Movie.new(self.video.current_path).duration.round(1)
	self.save
  end
end
