class CatchwordList < ApplicationRecord
  belongs_to :list, required: false
  has_many :catchword_list_entries, dependent: :destroy
  has_many :list_entries, through: :catchword_list_entries

  before_save do
    if self.catchword_list_entries.count != 0
      self.valide = true
    elsif self.list && self.list.list_entries.count != 0
      self.valide = true
    else
      self.valide = false
    end
  end
end
