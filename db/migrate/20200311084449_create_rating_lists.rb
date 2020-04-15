class CreateRatingLists < ActiveRecord::Migration[5.2]
  def change
    create_table :rating_lists do |t|
	  t.belongs_to :company, foreign_key: true
	  t.belongs_to :user, foreign_key: true
	  t.string :name
	  t.integer :image
      t.timestamps
    end
	change_table :games do |t|
	  t.belongs_to :rating_list, foreign_key: true
	end
  end
end
