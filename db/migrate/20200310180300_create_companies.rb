class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
	  t.string :name
	  t.string :logo
	  t.boolean :activated, default: false
	  t.integer :employees
	  t.string :message
	  t.integer :color1, array: true, default: [69, 177, 255]
	  t.integer :color2, array: true, default: [29, 218, 175]
      t.timestamps
    end
  end
end
