class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable, :trackable
  
  mount_uploader :avatar, AvatarUploader
	
  belongs_to :company
  belongs_to :department, required: false
  has_many :teams, dependent: :destroy
  has_many :team_users, dependent: :destroy
  has_many :games, dependent: :destroy
  has_many :catchword_lists, dependent: :destroy
  has_many :objection_lists, dependent: :destroy
  has_many :rating_lists, dependent: :destroy
  has_one :do_and_dont, dependent: :destroy
  has_many :game_turns, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :game_turn_ratings, dependent: :destroy
  has_many :user_ratings, dependent: :destroy
  has_one :coach, dependent: :destroy
  has_many :pitch_videos, dependent: :destroy
  has_many :comments, dependent: :destroy
	
  ROLES = %w[company_admin department_admin admin user].freeze
  BO_ROLES = %w[root sales].freeze
	
  before_save do
	self.role = 'user' if self.role.nil?
  end
	
  after_create do
	self.company.histories.create(history: 'Neuen Nutzer erstellt: ' + self.fname.to_s + ' ' + self.lname.to_s + '!', users: self.company.users.count)
	if self.role != 'user'
	  team = self.teams.create(name: 'all', company_id: self.company.id)
	  team.users << self
	end
  end
	
  after_update do
	if self.role != 'user' && self.teams.find_by(name: 'all').nil?
	  team = self.teams.create(name: 'all', company_id: self.company.id)
	  team.users << self
	end
  end
end
