class CreateRatingListRatingCriteria < ActiveRecord::Migration[5.2]
  def change
    create_table :rating_list_rating_criteria do |t|
      t.belongs_to :rating_list, foreign_key: true
      t.belongs_to :rating_criterium, foreign_key: true

      t.timestamps
    end
  end
end
