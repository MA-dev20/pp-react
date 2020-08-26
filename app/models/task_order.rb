class TaskOrder < ApplicationRecord
  belongs_to :task
  belongs_to :pitch

  before_save do
  	if self.order == 0
  	  self.order = self.pitch.tasks.count + 1
  	end
  end
end
