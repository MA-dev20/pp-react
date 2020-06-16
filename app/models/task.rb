class Task < ApplicationRecord
	belongs_to :company, required: false
	belongs_to :department, required: false
	belongs_to :team, required: false
    belongs_to :user
	belongs_to :task_medium, required: false
	belongs_to :catchword_list, required: false
	belongs_to :objection_list, required: false
	belongs_to :rating_list, required: false
	has_many :task_orders, dependent: :destroy
	has_many :pitches, through: :task_orders


    private

    def format_json_values value
        JSON(value)
    end
end