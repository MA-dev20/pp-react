class ObjectionListEntry < ApplicationRecord
  belongs_to :objection_list
  belongs_to :list_entry
end
