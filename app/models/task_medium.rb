class TaskMedium < ApplicationRecord
  mount_uploader :audio, SoundUploader
	mount_uploader :video, VideoUploader
	mount_uploader :image, ImageUploader
	mount_uploader :pdf, PdfUploader

  has_many :tasks
  belongs_to :company
  belongs_to :department, required: false
  belongs_to :team, required: false
  belongs_to :user
  belongs_to :content_folder, required: false

  def self.search(search)
    if search
      where('lower(title) LIKE ?', "%#{search.downcase}%")
    else
      scoped
    end
  end

	before_save do
	  if self.audio? &&
		self.duration = FFMPEG::Movie.new(self.audio.current_path).duration.round(1)
    self.title = self.audio_identifier if !self.title
	  elsif self.video?
		self.duration = FFMPEG::Movie.new(self.video.current_path).duration.round(1)
    self.title = self.video_identifier if !self.title
    elsif self.image
      self.title = self.image_identifier if !self.title
	  end
	end
end
