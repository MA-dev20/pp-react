class SharedContent < ApplicationRecord
  belongs_to :user
  belongs_to :task_medium, required: false
  belongs_to :catchword_list, required: false
  belongs_to :objection_list, required: false
end
