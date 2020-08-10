class Team < ApplicationRecord
  belongs_to :company
  belongs_to :department, required: false
  belongs_to :user
  has_many :team_users, dependent: :destroy
  has_many :users, through: :team_users
  has_many :pitches
  has_many :tasks
  has_many :task_media


  has_many :games, dependent: :destroy
  has_many :game_turns, dependent: :destroy
  has_many :game_ratings, dependent: :destroy
  has_many :team_ratings, dependent: :destroy

  mount_uploader :logo, LogoUploader

end
