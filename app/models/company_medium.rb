class CompanyMedium < ApplicationRecord
  belongs_to :company
  belongs_to :task_medium
end
