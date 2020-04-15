class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
	  t.belongs_to :game_turn, foreign_key: true
	  t.belongs_to :user, foreign_key: true
	  t.integer :time, default: 0
	  t.string :text
      t.timestamps
    end
  end
end
