class RatingCriterium < ApplicationRecord
  has_many :rating_list_rating_criteria, dependent: :destroy
  has_many :rating_lists, through: :rating_list_rating_criteria
  has_many :ratings, dependent: :destroy
  has_many :game_turn_ratings, dependent: :destroy
  has_many :game_ratings, dependent: :destroy
  has_many :user_ratings, dependent: :destroy
	
  def green
	if self.name == 'Körpersprache'
	  return 'game/ratings/body_green.png'
	elsif self.name == 'Kreativität'
	  return 'game/ratings/creative_green.png'
	elsif self.name == 'Rhetorik'
	  return 'game/ratings/rhetoric_green.png'
	else
	  return 'game/ratings/spontan_green.png'
	end
  end
  def blue
	if self.name == 'Körpersprache'
	  return 'game/ratings/body_blue.png'
	elsif self.name == 'Kreativität'
	  return 'game/ratings/creative_blue.png'
	elsif self.name == 'Rhetorik'
	  return 'game/ratings/rhetoric_blue.png'
	else
	  return 'game/ratings/spontan_blue.png'
	end
  end
end
