class GameUser < ApplicationRecord
  belongs_to :company
  belongs_to :game
  belongs_to :user

  before_save do
    self.company = self.game.company
  end
end
