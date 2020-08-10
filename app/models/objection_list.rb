class ObjectionList < ApplicationRecord
  belongs_to :company, required: false
  belongs_to :department, required: false
  belongs_to :team, required: false
  belongs_to :user, required: false
  belongs_to :content_folder, required: false
  belongs_to :game, required: false
  has_many :objection_list_objections, dependent: :destroy
  has_many :objections, through: :objection_list_objections

  before_create do
	self.image = Random.rand(8)
  end

  before_save do
    if self.content_folder
      self.available_for = self.content_folder.available_for
    end
  end

  def image_url
	return 'randomPics/objections/'+(self.image + 1).to_s+'.jpg'
  end

  def self.search(search)
    if search
      where('lower(name) LIKE ?', "%#{search.downcase}%")
    else
      scoped
    end
  end
end
