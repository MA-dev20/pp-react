class GameRating < ApplicationRecord
  belongs_to :game
  belongs_to :team
  belongs_to :rating_criterium
	
  after_save do
	self.game.update(ges_rating: self.game.game_ratings.average(:rating).round)
	@rating = self.team.team_ratings.find_by(rating_criterium_id: self.rating_criterium_id)
	@rating = self.team.team_ratings.create(rating_criterium_id: self.rating_criterium_id) if !@rating
	@rating.update(rating: self.team.game_ratings.where(rating_criterium_id: self.rating_criterium_id).average(:rating).round)
  end
end
