class UpdateComments < ActiveRecord::Migration[5.2]
  def change
	change_table :comments do |t|
	  t.string :positive
	end
  end
end
