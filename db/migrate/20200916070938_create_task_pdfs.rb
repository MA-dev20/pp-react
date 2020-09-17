class CreateTaskPdfs < ActiveRecord::Migration[5.2]
  def change
    create_table :task_pdfs do |t|
      t.belongs_to :company, required: false
      t.belongs_to :department, required: false
      t.belongs_to :team, required: false
      t.belongs_to :user, required: false
      t.belongs_to :content_folder, required: false
      t.string :name, default: 'PDF'
      t.string :available_for, default: 'user'
      t.timestamps
    end
    change_table :shared_contents do |t|
      t.belongs_to :task_pdf, foreign_key: true
    end
    change_table :task_media do |t|
      # t.remove :task_medium_id
      t.belongs_to :task_pdf, foreign_key: true
    end
  end
end
