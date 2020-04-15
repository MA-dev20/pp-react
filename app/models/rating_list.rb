class RatingList < ApplicationRecord
  belongs_to :company, required: false
  belongs_to :user, required: false
  has_many :rating_list_rating_criteria, dependent: :destroy
  has_many :rating_criteria, through: :rating_list_rating_criteria
	
  before_create do
	self.image = Random.rand(8)
  end
	
  def image_url
	return 'randomPics/ratings/'+(self.image + 1).to_s+'.jpg'
  end
end
