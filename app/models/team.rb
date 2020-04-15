class Team < ApplicationRecord
  belongs_to :company
  belongs_to :department, required: false
  belongs_to :user
  has_many :team_users, dependent: :destroy
  has_many :users, through: :team_users
  has_many :games, dependent: :destroy
  has_many :game_turns, dependent: :destroy
  has_many :game_ratings, dependent: :destroy
  has_many :team_ratings, dependent: :destroy
	
  mount_uploader :logo, LogoUploader
	
  after_create do
	self.company.histories.create(history: 'Neues Team erstellt: ' + self.name + '!', users: self.company.users.count, department_id: self.department_id)
  end
end
