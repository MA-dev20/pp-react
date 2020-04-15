class CreateGameTurns < ActiveRecord::Migration[5.2]
  def change
    create_table :game_turns do |t|
      t.belongs_to :game, foreign_key: true
      t.belongs_to :user, foreign_key: true
	  t.belongs_to :team, foregin_key: true
      t.belongs_to :catchword, foreign_key: true
		
	  t.integer :counter, default: 0
	  t.boolean :choosen, default: false	  
		
	  t.boolean :play, default: true
	  t.boolean :played, default: false
	  t.integer :place
		
	  t.boolean :record_pitch, default: false

	  t.integer :ges_rating, default: 0

      t.timestamps
    end
  end
end
