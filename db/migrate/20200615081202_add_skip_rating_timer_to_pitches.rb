class AddSkipRatingTimerToPitches < ActiveRecord::Migration[5.2]
  def change
    add_column :pitches, :skip_rating_timer, :boolean, default: false
  end
end
