class Team < ApplicationRecord
  belongs_to :company
  belongs_to :department, required: false
  belongs_to :user
  has_many :team_users, dependent: :destroy
  has_many :users, through: :team_users
  has_many :pitches
  has_many :tasks
  has_many :task_media


  has_many :games
  has_many :game_turns
  has_many :game_ratings
  has_many :team_ratings, dependent: :destroy

  mount_uploader :logo, LogoUploader

  before_destroy do
    self.pitches.each do |pitch|
      pitch.update(team: nil)
    end
    self.tasks.each do |task|
      task.update(team: nil)
    end
    self.task_media.each do |media|
      media.update(team: nil)
    end
    self.games.each do |game|
      game.update(team: nil)
    end
    self.game_turns.each do |turn|
      turn.update(team: nil)
    end
    self.game_ratings.each do |rating|
      rating.update(team: nil)
    end
  end

end
