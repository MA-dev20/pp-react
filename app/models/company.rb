class Company < ApplicationRecord
  mount_uploader :logo, LogoUploader

  has_many :departments, dependent: :destroy
  has_many :histories, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :company_users, dependent: :destroy
  has_many :user_users, dependent: :destroy
  has_many :users, through: :company_users
  has_many :user_abilities, dependent: :destroy
  has_many :games, dependent: :destroy
  has_many :pitches, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :task_media, dependent: :destroy
  has_many :content_folders, dependent: :destroy
  has_many :pitch_videos, dependent: :destroy

  has_many :catchword_lists, dependent: :destroy
  has_many :catchwords, dependent: :destroy
  has_many :objection_lists, dependent: :destroy
  has_many :objections, dependent: :destroy
  has_many :rating_lists, dependent: :destroy
  has_many :do_and_donts, dependent: :destroy
  has_many :videos, dependent: :destroy


  after_create do
	self.histories.create(history: 'Unternehmen erstellt!', users: self.users.count)
  end
  after_update do
    if self.previous_changes[:color_hex]
      red_string = self.color_hex[1] + self.color_hex[2]
      green_string = self.color_hex[3] + self.color_hex[4]
      blue_string = self.color_hex[5] + self.color_hex[6]
      self.color1[0] = red_string.hex.to_i
      self.color1[1] = green_string.hex.to_i
      self.color1[2] = blue_string.hex.to_i
      self.color2[0] = red_string.hex.to_i
      self.color2[1] = green_string.hex.to_i
      self.color2[2] = blue_string.hex.to_i
      self.save
    end
  end
end
