class TaskMedium < ApplicationRecord
    mount_uploader :audio, SoundUploader
	mount_uploader :video, VideoUploader
end
