class CreateCatchwords < ActiveRecord::Migration[5.2]
  def change
    create_table :catchwords do |t|
	  t.belongs_to :company, foreign_key: true
		
	  t.string :name, :sound

      t.timestamps
    end
  end
end
