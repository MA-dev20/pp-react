class TeamRating < ApplicationRecord
  belongs_to :team
  belongs_to :rating_criterium

  after_save do
	self.team.update(ges_rating: self.team.team_ratings.average(:rating))
  end
end
