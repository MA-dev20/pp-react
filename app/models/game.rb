class Game < ApplicationRecord
  belongs_to :company
  belongs_to :user
  belongs_to :team
  belongs_to :pitch, required: false
  has_many :game_turns, dependent: :destroy
  has_many :game_ratings, dependent: :destroy
  has_many :game_turn_ratings
  has_many :game_users, dependent: :destroy

  before_create do
	  self.state = 'wait'
  end
  after_update do
  	if self.previous_changes["state"]
  	  ActionCable.server.broadcast "game_#{self.id}_channel", game_state: 'changed'
    elsif self.state == 'turn' && self.previous_changes['current_turn']
      ActionCable.server.broadcast "game_#{self.id}_channel", game_state: 'changed'
    elsif self.state == 'show_task' && self.previous_changes['current_task']
      ActionCable.server.broadcast "game_#{self.id}_channel", game_state: 'changed'
    end
  end
end
