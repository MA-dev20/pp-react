class ObjectionListObjection < ApplicationRecord
  belongs_to :objection_list
  belongs_to :objection
end
