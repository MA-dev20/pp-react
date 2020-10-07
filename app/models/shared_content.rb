class SharedContent < ApplicationRecord
  belongs_to :user
  belongs_to :task_medium, required: false
  belongs_to :task_pdf, required: false
  belongs_to :list, required: false
end
