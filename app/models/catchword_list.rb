class CatchwordList < ApplicationRecord
  belongs_to :company, required: false
  belongs_to :user, required: false
  belongs_to :game, required: false
  has_many :catchword_list_catchwords, dependent: :destroy
  has_many :catchwords, through: :catchword_list_catchwords
	
  before_create do
	self.image = Random.rand(8)
  end
	
  def image_url
	return 'randomPics/catchwords/'+(self.image + 1).to_s+'.jpg'
  end
end
