class Task < ApplicationRecord
    belongs_to :user
    belongs_to :pitch

    private

    def format_json_values value
        JSON(value)
    end
end
