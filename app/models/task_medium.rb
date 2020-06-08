class TaskMedium < ApplicationRecord
    mount_uploader :audio, SoundUploader
end