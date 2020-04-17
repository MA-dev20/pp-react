class Video < ApplicationRecord
  belongs_to :user
  belongs_to :company, required: false
  belongs_to :department, required: false

  mount_uploader :video, PitchUploader
end
