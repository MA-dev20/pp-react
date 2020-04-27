class AddUserCountToGames < ActiveRecord::Migration[5.2]
  def change
	add_column :games, :max_users, :integer, default: 0
  end
end
