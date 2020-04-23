class Rating < ApplicationRecord
  belongs_to :game_turn
  belongs_to :user
  belongs_to :rating_criterium
	
  after_save do
	@ratings = self.game_turn.ratings.where(rating_criterium_id: self.rating_criterium_id).all
	@rating = self.game_turn.game_turn_ratings.find_by(rating_criterium_id: self.rating_criterium.id)
	@rating = self.game_turn.game_turn_ratings.create(rating_criterium_id: self.rating_criterium.id, user_id: self.game_turn.user_id, game_id: self.game_turn.game.id) if @rating.nil?
	@rating.update(rating: @ratings.average(:rating).round)
  end
end
