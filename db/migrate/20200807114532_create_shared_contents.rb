class CreateSharedContents < ActiveRecord::Migration[5.2]
  def change
    create_table :shared_contents do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :task_medium, foreign_key: true
      t.belongs_to :catchword_list, foreign_key: true
      t.belongs_to :objection_list, foreign_key: true
      t.timestamps
    end
    create_table :shared_folders do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :content_folder, foreign_key: true
      t.timestamps
    end
  end
end
