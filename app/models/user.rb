class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable, :trackable

  mount_uploader :avatar, AvatarUploader

  has_many :company_users, dependent: :destroy
  has_many :companies, through: :company_users
  has_many :catchwords, dependent: :destroy
  has_many :task_media, dependent: :destroy
  has_many :content_folders, dependent: :destroy
  has_many :catchword_lists, dependent: :destroy
  has_many :catchwords, dependent: :destroy
  has_many :objection_lists, dependent: :destroy
  has_many :objections, dependent: :destroy
  has_many :shared_folders, dependent: :destroy
  has_many :shared_content, dependent: :destroy
  has_many :shared_pitches, dependent: :destroy

  has_many :teams, dependent: :destroy
  has_many :team_users, dependent: :destroy
  has_many :games, dependent: :destroy
  has_many :game_users, dependent: :destroy


  has_many :rating_lists, dependent: :destroy
  has_one :do_and_dont, dependent: :destroy
  has_many :game_turns, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :game_turn_ratings, dependent: :destroy
  has_many :user_ratings, dependent: :destroy
  has_one :coach, dependent: :destroy
  has_many :pitch_videos, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :videos, dependent: :destroy

  has_many :pitches
  has_many :tasks

  ROLES = %w[company_admin department_admin admin user].freeze
  BO_ROLES = %w[root sales].freeze
end
