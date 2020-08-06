class Objection < ApplicationRecord
  belongs_to :company, required: false
  belongs_to :department, required: false
  belongs_to :team, required: false
  belongs_to :user, required: false
  has_many :objection_list_objections, dependent: :destroy
  has_many :objection_lists, through: :objection_list_objections

  mount_uploader :sound, SoundUploader
end
