class Game < ApplicationRecord
  belongs_to :company
  belongs_to :user
  belongs_to :team
  belongs_to :rating_list, required: false
  has_one :catchword_list, dependent: :destroy
  has_one :objection_list, dependent: :destroy
  has_many :game_turns, dependent: :destroy
  has_many :game_ratings, dependent: :destroy
  has_many :game_turn_ratings
	
  before_create do
	self.state = 'wait'
  end
end
