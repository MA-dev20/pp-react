class ObjectionList < ApplicationRecord
  belongs_to :list, required: false
  has_many :objection_list_entries, dependent: :destroy
  has_many :list_entries, through: :objection_list_entries

end
