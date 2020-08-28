class ChangeRatingsToNewLogic < ActiveRecord::Migration[5.2]
  def change
    change_table :user_ratings do |t|
      t.belongs_to :company
    end
    change_table :game_turn_ratings do |t|
      t.belongs_to :company
    end
    change_table :game_users do |t|
      t.belongs_to :company
    end
  end
end
