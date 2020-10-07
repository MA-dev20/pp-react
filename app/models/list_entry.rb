class ListEntry < ApplicationRecord
  belongs_to :company, required: false
  belongs_to :user, required: false
  has_many :list_entry_lists, dependent: :destroy
  has_many :lists, through: :list_entry_lists
  has_many :catchword_list_entries, dependent: :destroy
  has_many :catchword_lists, through: :catchword_list_entries
  has_many :objection_list_entries, dependent: :destroy
  has_many :objection_lists, through: :objection_list_entries
  has_many :game_turns, dependent: :destroy

  mount_uploader :sound, SoundUploader
end
