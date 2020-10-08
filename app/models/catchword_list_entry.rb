class CatchwordListEntry < ApplicationRecord
  belongs_to :catchword_list
  belongs_to :list_entry
  after_save do
    self.catchword_list.update(valide: true) if !self.catchword_list.valide
  end
end
