class CreateContentFolders < ActiveRecord::Migration[5.2]
  def change
    create_table :content_folders do |t|
      t.belongs_to :company
      t.belongs_to :department
      t.belongs_to :team
      t.belongs_to :user
      t.belongs_to :content_folder
      t.string :name
      t.timestamps
    end
    change_table :task_media do |t|
      t.belongs_to :content_folder
      t.string :title
    end
    change_table :catchword_lists do |t|
      t.belongs_to :content_folder
    end
    change_table :objection_lists do |t|
      t.belongs_to :content_folder
    end
  end
end
