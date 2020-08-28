class GameUser < ApplicationRecord
  belongs_to :company
  belongs_to :game
  belongs_to :user

  before_save do
    self.company = self.game.company
  end
  after_save do
    game = self.game
    i = 1
    game.game_users.order(best_rating: :desc).each do |gu|
      gu.update(place: i) if gu.place != i && gu.best_rating != 0
      i += 1
    end
  end
end
