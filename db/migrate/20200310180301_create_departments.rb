class CreateDepartments < ActiveRecord::Migration[5.2]
  def change
    create_table :departments do |t|
	  t.belongs_to :company, foreign_key: true
	  t.string :name
	  t.string :logo
      t.timestamps
    end
  end
end
