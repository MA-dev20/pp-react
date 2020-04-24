class AddSkipElectionsToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :skip_elections, :boolean, default: false
  end
end
