class Task < ApplicationRecord
  belongs_to :user
  belongs_to :pitch

  # serialize :catchwords, Array
end
