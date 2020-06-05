class Game < ApplicationRecord
  belongs_to :company
  belongs_to :user
  belongs_to :team
  belongs_to :pitch, required: false
  has_many :game_turns, dependent: :destroy
  has_many :game_ratings, dependent: :destroy
  has_many :game_turn_ratings
	
  before_create do
	self.state = 'wait'
  end
  after_update do
	if self.previous_changes["state"] || self.previous_changes['current_turn']
	  ActionCable.server.broadcast "game_#{self.id}_channel", game_state: 'changed'
	end
  end
end
