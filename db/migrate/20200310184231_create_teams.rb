class CreateTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :teams do |t|
	  t.belongs_to :company, foreign_key: true
	  t.belongs_to :department, foreign_key: true
	  t.belongs_to :user, foreign_key: true
	  t.string :name
	  t.string :logo
	  t.integer :ges_rating, default: 0
      t.timestamps
    end
  end
end
