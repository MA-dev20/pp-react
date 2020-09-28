class ChangeGame < ActiveRecord::Migration[5.2]
  def change
    change_column :games, :skip_rating_timer, :boolean, default: true
  end
end
