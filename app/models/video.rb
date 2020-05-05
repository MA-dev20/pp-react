class Video < ApplicationRecord
  belongs_to :user
  belongs_to :company, required: false
  belongs_to :department, required: false

  mount_uploader :video, PitchUploader
	
  after_create do
	self.duration = FFMPEG::Movie.new(self.video.current_path).duration.round(1)
	self.save
  end
end
