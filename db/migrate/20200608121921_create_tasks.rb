class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.belongs_to :company, foreign_key: true
	  t.belongs_to :department, foreign_key: true
	  t.belongs_to :team, foreign_key: true
	  t.belongs_to :user, foreign_key: true
      t.string :task_type
      t.string :title
      t.integer :time
	  t.belongs_to :task_medium, foreign_key: true
	  t.integer :task_slide, default: 0
	  t.boolean :valide, default: false
	  t.belongs_to :catchword_list, foreign_key: true
	  t.belongs_to :objection_list, foreign_key: true
      t.belongs_to :rating_list, foreign_key: true
      t.timestamps
    end
  end
end
