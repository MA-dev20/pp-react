class TaskMedium < ApplicationRecord
  mount_uploader :audio, SoundUploader
	mount_uploader :video, VideoUploader
	mount_uploader :image, ImageUploader
	mount_uploader :pdf, PdfUploader

  has_many :tasks, dependent: :destroy
  has_many :company_media, dependent: :destroy
  has_many :companies, through: :company_media

	before_save do
	  if self.audio? &&
		self.duration = FFMPEG::Movie.new(self.audio.current_path).duration.round(1)
	  elsif self.video?
		self.duration = FFMPEG::Movie.new(self.video.current_path).duration.round(1)
	  end
	end
end
