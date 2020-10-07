class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable, :trackable

  belongs_to :user, required: false
  mount_uploader :avatar, AvatarUploader

  has_many :company_users, dependent: :destroy
  has_many :companies, through: :company_users
  has_many :department_users, dependent: :destroy
  has_many :departments, through: :department_users
  has_many :teams, dependent: :destroy
  has_many :team_users, dependent: :destroy
  has_many :user_users, dependent: :destroy

  has_many :content_folders
  has_many :catchword_lists
  has_many :catchwords
  has_many :objection_lists
  has_many :objections
  has_many :task_media
  has_many :task_pdfs

  has_many :pitches
  has_many :tasks

  has_many :shared_folders, dependent: :destroy
  has_many :shared_content, dependent: :destroy
  has_many :shared_pitches, dependent: :destroy

  has_many :games
  has_many :game_turns, dependent: :destroy
  has_many :game_turn_ratings, dependent: :destroy
  has_many :game_users, dependent: :destroy

  has_many :user_ratings, dependent: :destroy

  has_many :ratings
  has_many :own_ratings, dependent: :destroy

  has_many :pitch_videos
  has_many :comments

  before_save { self.email.downcase! }

  before_destroy do
    self.content_folders.each do |folder|
      if folder.shared_folders.count != 0 || folder.available_for != 'user'
        folder.destroy
      else
        folder.update(user: nil)
      end
    end

    self.catchword_lists.each do |list|
      if list.shared_contents.count != 0 || list.available_for != 'user'
        list.destroy
      else
        list.update(user: nil)
      end
    end

    self.objection_lists.each do |list|
      if list.shared_contents.count != 0 || list.available_for != 'user'
        list.destroy
      else
        list.update(user: nil)
      end
    end

    self.catchwords.each do |word|
      word.update(user: nil)
    end

    self.objections.each do |word|
      word.update(user: nil)
    end

    self.task_media.each do |media|
      if media.shared_contents.count != 0 || media.available_for != 'user' || media.tasks.count != 0
        media.destroy
      else
        media.update(user: nil)
      end
    end

    self.pitches.each do |pitch|
      if pitch.shared_pitches.count != 0 || pitch.available_for != 'user'
        pitch.destroy
      else
        pitch.update(user: nil)
      end
    end

    self.tasks.each do |task|
      task.update(user: nil)
    end

    self.pitch_videos.each do |video|
      video.update(user: nil)
    end

    self.comments.each do |comment|
      comment.update(user: nil)
    end

    self.games.each do |game|
      game.update(user: nil)
    end
    self.ratings.each do |rating|
      rating.update(user: nil)
    end
  end

  def self.search(search)
    if search
      where('lower(fname) LIKE ?', "%#{search.downcase}%")
      where('lower(lname) LIKE ?', "%#{search.downcase}%")
      where('lower(email) LIKE ?', "%#{search.downcase}%")
    else
      scoped
    end
  end

end
