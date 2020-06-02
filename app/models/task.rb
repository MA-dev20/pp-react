class Task < ApplicationRecord
    belongs_to :user
    belongs_to :pitch

    mount_uploader :image, ImageUploader
    mount_uploader :video, VideoUploader
    mount_uploader :audio, SoundUploader

    # after_create do
    #     self.duration = FFMPEG::Movie.new(self.video.current_path).duration.round(1)
    #     self.save
    # end

    # Task.group(:video, :pitch_id).count
    private

    def format_json_values value
        JSON(value)
    end
end
