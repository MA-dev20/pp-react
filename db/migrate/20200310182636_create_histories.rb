class CreateHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :histories do |t|
	  t.belongs_to :company, foreign_key: true
	  t.belongs_to :department, foreign_key: true
	  t.belongs_to :user, foreign_key: true
	  t.integer :users
	  t.string :history
      t.timestamps
    end
  end
end