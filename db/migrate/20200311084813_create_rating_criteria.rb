class CreateRatingCriteria < ActiveRecord::Migration[5.2]
  def change
    create_table :rating_criteria do |t|
      t.string :name
	  t.string :icon, default: 'fa-star'

      t.timestamps
    end
  end
end
