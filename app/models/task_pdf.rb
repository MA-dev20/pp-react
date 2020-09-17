class TaskPdf < ApplicationRecord
  has_many :task_media, dependent: :destroy
  has_many :shared_contents, dependent: :destroy

  belongs_to :company, required: false
  belongs_to :user, required: false
  belongs_to :content_folder, required: false

end
