class DoAndDont < ApplicationRecord
  belongs_to :company, required: false
  belongs_to :department, required: false
  belongs_to :user, required: false
  serialize :does
  serialize :donts
end
