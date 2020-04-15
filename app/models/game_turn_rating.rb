class GameTurnRating < ApplicationRecord
  belongs_to :game
  belongs_to :game_turn
  belongs_to :user
  belongs_to :rating_criterium
	
  after_save do
	@ratings = self.game.game_turn_ratings.where(rating_criterium_id: self.rating_criterium_id).all
	@rating = self.game.game_ratings.find_by(rating_criterium_id: self.rating_criterium.id)
	@rating = self.game.game_ratings.create(rating_criterium_id: self.rating_criterium.id, team_id: self.game.team_id) if !@rating
	@rating.update(rating: @ratings.average(:rating))
	self.game_turn.update(ges_rating: self.game_turn.game_turn_ratings.average(:rating))
  end
end
