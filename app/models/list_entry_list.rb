class ListEntryList < ApplicationRecord
  belongs_to :list
  belongs_to :list_entry
end
