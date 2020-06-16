class CreateTaskOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :task_orders do |t|
	  t.belongs_to :pitch, foreign_key: true
	  t.belongs_to :task, foreign_key: true
	  t.integer :order, default: 0
      t.timestamps
    end
  end
end
