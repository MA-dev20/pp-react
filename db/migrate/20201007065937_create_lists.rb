class CreateLists < ActiveRecord::Migration[5.2]
  def change
    create_table :lists do |t|
      t.belongs_to :company, foreign_key: true
      t.belongs_to :department, foreign_key: true
      t.belongs_to :team, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.belongs_to :content_folder, foreign_key: true

      t.string :name
      t.string :available_for, default: 'user'

      t.timestamps
    end
  end
end
