class TaskMedium < ApplicationRecord
    mount_uploader :audio, SoundUploader
	mount_uploader :video, VideoUploader
	mount_uploader :image, ImageUploader
	mount_uploader :pdf, PdfUploader
	
	before_save do
	  if self.audio? && 
		self.duration = FFMPEG::Movie.new(self.audio.current_path).duration.round(1)
	  elsif self.video?
		self.duration = FFMPEG::Movie.new(self.video.current_path).duration.round(1)
	  end
	end
end
