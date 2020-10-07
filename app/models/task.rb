class Task < ApplicationRecord
	belongs_to :company, required: false
	belongs_to :department, required: false
	belongs_to :team, required: false
  belongs_to :user, required: false
	belongs_to :task_medium, required: false
	belongs_to :catchword_list, required: false
	belongs_to :objection_list, required: false
	belongs_to :rating_list, required: false
	has_many :task_orders, dependent: :destroy
	has_many :pitches, through: :task_orders

	before_save do
		if self.user
			user = User.find(self.user_id)
			self.company_id = user.company_ids.first if self.company_id.nil?
		end
		if self.rating1 == ''
			self.rating1 = nil
		elsif self.rating2 == ''
			self.rating2 = nil
		elsif self.rating3 == ''
			self.rating3 = nil
		elsif self.rating4 == ''
			self.rating4 = nil
		end
	end
	after_save do
		if self.task_type == 'slide' && self.task_medium && self.task_medium.valide
			self.update(valide: true) if !self.valide
		elsif self.title.present? && self.title != ''
			if self.task_type == 'catchword' && self.catchword_list && self.catchword_list.valide
				self.update(valide: true) if !self.valide
			elsif self.task_type == ''
				if self.catchword_list && self.catchword_list.valide
					self.update(valide: true, task_type: 'catchword')
				elsif self.task_medium && self.task_medium.valide
					self.update(valide: true, task_type: self.task_medium.media_type)
				end
			elsif self.task_medium && self.task_medium.valide
				self.update(valide: true) if !self.valide
			else
				self.update(valide: false) if self.valide
			end
	  else
		  self.update(valide: false) if self.valide
	  end
	end

    private

    def format_json_values value
        JSON(value)
    end
end
