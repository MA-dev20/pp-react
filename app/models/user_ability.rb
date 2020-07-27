class UserAbility < ApplicationRecord
  belongs_to :company, required: false
end
