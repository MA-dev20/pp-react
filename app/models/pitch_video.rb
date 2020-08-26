class PitchVideo < ApplicationRecord
  belongs_to :game_turn
  belongs_to :user, required: false
  belongs_to :company

  mount_uploader :video, PitchUploader

  before_save do
    if !self.company
      self.company = self.game_turn.game.company
    end
  end
  after_create do
	self.duration = FFMPEG::Movie.new(self.video.current_path).duration.round(1)
	self.save
  end
end
