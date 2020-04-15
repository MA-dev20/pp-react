class Company < ApplicationRecord
  mount_uploader :logo, LogoUploader

  has_many :departments, dependent: :destroy
  has_many :histories, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :games, dependent: :destroy
  has_many :catchword_lists, dependent: :destroy
  has_many :catchwords, dependent: :destroy
  has_many :objection_lists, dependent: :destroy
  has_many :objections, dependent: :destroy
  has_many :rating_lists, dependent: :destroy
  has_many :do_and_donts, dependent: :destroy
  has_one :coach, dependent: :destroy
	
  after_create do
	self.histories.create(history: 'Unternehmen erstellt!', users: self.users.count)
  end
end
