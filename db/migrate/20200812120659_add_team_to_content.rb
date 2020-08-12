class AddTeamToContent < ActiveRecord::Migration[5.2]
  def change
    change_table :objection_lists do |t|
      t.belongs_to :department, foreign_key: true
      t.belongs_to :team, foreign_key: true
    end
    change_table :catchword_lists do |t|
      t.belongs_to :department, foreign_key: true
      t.belongs_to :team, foreign_key: true
    end
  end
end
