class CreateGameUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :game_users do |t|
      t.belongs_to :game, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.integer :turn_count, default: 0
      t.boolean :play, default: true
      t.boolean :active, default: true
      t.integer :best_rating, default: 0
      t.integer :place
      t.timestamps
    end
  end
end
