class CatchwordListEntry < ApplicationRecord
  belongs_to :catchword_list
  belongs_to :list_entry
end
