class AddRatingsToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :rating1, :string
    add_column :tasks, :rating2, :string
    add_column :tasks, :rating3, :string
    add_column :tasks, :rating4, :string
  end
end
