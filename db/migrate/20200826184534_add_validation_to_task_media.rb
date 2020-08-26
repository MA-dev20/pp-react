class AddValidationToTaskMedia < ActiveRecord::Migration[5.2]
  def change
    change_table :task_media do |t|
      t.boolean :valide, default: false
    end
  end
end
