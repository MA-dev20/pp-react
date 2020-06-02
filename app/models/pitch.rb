class Pitch < ApplicationRecord
    has_many :tasks

    mount_uploader :image, ImageUploader
    mount_uploader :video, VideoUploader
    
    accepts_nested_attributes_for :tasks, reject_if: :all_blank, allow_destroy: true 

    def self.videos_count
        joins(:tasks).group('tasks.video', 'tasks.pitch_id').count
    end

    def self.images_count
        joins(:tasks).group('tasks.image', 'tasks.pitch_id').count
    end
end
