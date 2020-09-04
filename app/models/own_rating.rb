class OwnRating < ApplicationRecord
  belongs_to :game_turn
  belongs_to :user
  belongs_to :rating_criterium
end
