class ChangeAskMedia < ActiveRecord::Migration[5.2]
  def change
    change_table :task_media do |t|
      t.boolean :is_pdf, default: false
      t.belongs_to :task_medium, foreign_key: true
    end
  end
end
