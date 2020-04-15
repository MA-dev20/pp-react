class CreateUserRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :user_ratings do |t|
	  t.belongs_to :user, foreign_key: true
	  t.belongs_to :rating_criterium, foreign_key: true
	  t.integer :rating, default: 0
	  t.integer :change, default: 0
      t.timestamps
    end
  end
end
