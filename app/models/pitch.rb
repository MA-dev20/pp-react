class Pitch < ApplicationRecord
	belongs_to :company, required: false
	belongs_to :department, required: false
	belongs_to :team, required: false
	belongs_to :user
    has_many :task_orders, dependent: :destroy
	has_many :tasks, through: :task_orders

    mount_uploader :image, ImageUploader
    mount_uploader :video, VideoUploader

    accepts_nested_attributes_for :tasks, reject_if: :all_blank, allow_destroy: true

		before_save do
			user = User.find(self.user_id)
			self.company_id = user.company_id if self.company_id.nil?
		end
		
    def self.videos_count
        joins(:tasks).group('tasks.video', 'tasks.pitch_id').count
    end

    def self.images_count
        joins(:tasks).group('tasks.image', 'tasks.pitch_id').count
    end
end
