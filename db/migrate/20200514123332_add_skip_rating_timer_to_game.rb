class AddSkipRatingTimerToGame < ActiveRecord::Migration[5.2]
  def change
	add_column :games, :skip_rating_timer, :boolean, default: false
  end
end
