class AddTaskPdfMediTypeToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :pdf_type, :string, default: 'image'
  end
end
