class TaskMedium < ApplicationRecord
  mount_uploader :audio, SoundUploader
	mount_uploader :video, VideoUploader
	mount_uploader :image, ImageUploader
	mount_uploader :pdf, PdfUploader

  has_many :tasks
  belongs_to :company, required: false
  belongs_to :department, required: false
  belongs_to :team, required: false
  belongs_to :user, required: false
  belongs_to :content_folder, required: false
  belongs_to :task_medium, required: false
  has_many :shared_contents, dependent: :destroy

  def self.search(search)
    if search
      where('lower(title) LIKE ?', "%#{search.downcase}%")
    else
      scoped
    end
  end
  after_save do
    if self.previous_changes["valide"]
      Task.where(task_medium: self).each do |t|
        t.update(valide: self.valide) if t.valide != self.valide
      end
    end
  end

  before_destroy do
    Task.where(task_medium: self).each do |t|
      t.update(task_medium_id: nil, valide: false)
    end
  end

  before_save do
	  if self.audio?
		  self.duration = FFMPEG::Movie.new(self.audio.current_path).duration.round(1)
      self.title = self.audio_identifier if !self.title || self.title == ''
      self.media_type = 'audio'
      self.valide = true
	  elsif self.video?
		  self.duration = FFMPEG::Movie.new(self.video.current_path).duration.round(1)
      self.title = self.video_identifier if !self.title || self.title == ''
      self.media_type = 'video'
      self.valide = true
    elsif self.image?
      self.title = self.image_identifier if !self.title || self.title == ''
      self.media_type = 'image'
      self.valide = true
    elsif self.pdf?
      self.title = self.pdf_identifier if !self.title || self.title == ''
      self.media_type = 'pdf'
      self.valide = true
	  end
    if self.content_folder
      self.available_for = self.content_folder.available_for
    end
	end
end
