class AddDefaultValueToTasksTimeAttribute < ActiveRecord::Migration[5.2]
  def change
    change_column :tasks, :time, :integer, default: 80
  end
end
