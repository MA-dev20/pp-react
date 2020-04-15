class CreateCatchwordListCatchwords < ActiveRecord::Migration[5.2]
  def change
    create_table :catchword_list_catchwords do |t|
	  t.belongs_to :catchword_list, foreign_key: true
	  t.belongs_to :catchword, foreign_key: true
      t.timestamps
    end
  end
end
