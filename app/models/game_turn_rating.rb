class GameTurnRating < ApplicationRecord
  belongs_to :company
  belongs_to :game
  belongs_to :game_turn
  belongs_to :user
  belongs_to :rating_criterium

  before_save do
    self.company = Game.find_by(id: self.game_id).company
  end
  after_save do
  	@ratings = self.game.game_turn_ratings.where(rating_criterium_id: self.rating_criterium_id).all
  	@rating = self.game.game_ratings.find_by(rating_criterium_id: self.rating_criterium.id)
  	@rating = self.game.game_ratings.create(rating_criterium_id: self.rating_criterium.id, team_id: self.game.team_id) if !@rating
  	@rating.update(rating: @ratings.average(:rating).round)

    user_ratings = GameTurnRating.where(company: self.company, user: self.user, rating_criterium: self.rating_criterium).all
    user_rating = self.user.user_ratings.find_by(company: self.company, rating_criterium: self.rating_criterium)
    user_rating = self.user.user_ratings.create(company: self.company, rating_criterium: self.rating_criterium) if !user_rating
    user_rating.update(rating: user_ratings.average(:rating).round)

    self.game_turn.update(ges_rating: self.game_turn.game_turn_ratings.average(:rating).round)
  end
end
