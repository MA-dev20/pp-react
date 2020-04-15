class UserRating < ApplicationRecord
  belongs_to :user
  belongs_to :rating_criterium
end
