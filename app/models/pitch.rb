class Pitch < ApplicationRecord
	belongs_to :company, required: false
	belongs_to :department, required: false
	belongs_to :team, required: false
	belongs_to :user, required: false
	has_many :games
  has_many :task_orders, dependent: :destroy
	has_many :tasks, through: :task_orders
	has_many :shared_pitches, dependent: :destroy

  mount_uploader :image, ImageUploader
  mount_uploader :video, VideoUploader

  def self.videos_count
  	joins(:tasks).group('tasks.video', 'tasks.pitch_id').count
  end

  def self.images_count
    joins(:tasks).group('tasks.image', 'tasks.pitch_id').count
  end
end
