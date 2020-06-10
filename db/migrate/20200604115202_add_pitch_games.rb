class AddPitchGames < ActiveRecord::Migration[5.2]
  def change
    change_table :games do |t|
      t.belongs_to :pitch, foreign_key: true
    end
    change_table :game_turns do |t|
      t.belongs_to :task, foreign_key: true
    end
  end
end
