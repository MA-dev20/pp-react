class AddRepeatToTurns < ActiveRecord::Migration[5.2]
  def change
	add_column :game_turns, :repeat, :boolean, default: false
  end
end
