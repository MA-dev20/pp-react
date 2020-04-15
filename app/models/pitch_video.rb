class PitchVideo < ApplicationRecord
  belongs_to :game_turn
  belongs_to :user
  
  mount_uploader :video, PitchUploader
end
