class AddShowRatingsToGames < ActiveRecord::Migration[5.2]
  def change
	add_column :games, :show_ratings, :string, default: "all"
	add_column :games, :rating_user, :integer
  end
end
