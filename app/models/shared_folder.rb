class SharedFolder < ApplicationRecord
  belongs_to :user
  belongs_to :content_folder
end
