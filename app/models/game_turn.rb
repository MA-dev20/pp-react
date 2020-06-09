class GameTurn < ApplicationRecord
  belongs_to :game
  belongs_to :team
  belongs_to :user
  belongs_to :task, required: false
  has_many :ratings, dependent: :destroy
  has_many :game_turn_ratings, dependent: :destroy
  has_one :pitch_video, dependent: :destroy
  has_many :comments, dependent: :destroy
	
  scope :playable, -> {where(play: true, played: false)}
end
