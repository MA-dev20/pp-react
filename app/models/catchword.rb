class Catchword < ApplicationRecord
  belongs_to :company, required: false
  belongs_to :user, required: false
  has_many :catchword_list_catchwords, dependent: :destroy
  has_many :catchword_lists, through: :catchword_list_catchwords

  mount_uploader :sound, SoundUploader
end
