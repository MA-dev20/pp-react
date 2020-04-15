class CreateCatchwordLists < ActiveRecord::Migration[5.2]
  def change
    create_table :catchword_lists do |t|
	  t.belongs_to :company, foreign_key: true
	  t.belongs_to :user, foreign_key: true
	  t.belongs_to :game, foreign_key: true
	  t.string :name
	  t.integer :image
      t.timestamps
    end
  end
end
