class AddUserRelations < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :color_hex, :string
    create_table :company_users do |t|
      t.belongs_to :company, foreign_key: true
  	  t.belongs_to :user, foreign_key: true
      t.timestamps
    end
    create_table :company_media do |t|
      t.belongs_to :company, foreign_key: true
  	  t.belongs_to :task_medium, foreign_key: true
      t.timestamps
    end
    create_table :company_pitches do |t|
      t.belongs_to :company, foreign_key: true
  	  t.belongs_to :pitch, foreign_key: true
      t.timestamps
    end
    create_table :department_users do |t|
      t.belongs_to :department, foreign_key: true
  	  t.belongs_to :user, foreign_key: true
      t.timestamps
    end
    create_table :department_media do |t|
      t.belongs_to :department, foreign_key: true
  	  t.belongs_to :task_medium, foreign_key: true
      t.timestamps
    end
    create_table :department_pitches do |t|
      t.belongs_to :department, foreign_key: true
  	  t.belongs_to :pitch, foreign_key: true
      t.timestamps
    end
    create_table :team_media do |t|
      t.belongs_to :team, foreign_key: true
  	  t.belongs_to :task_media, foreign_key: true
      t.timestamps
    end
    create_table :team_pitches do |t|
      t.belongs_to :team, foreign_key: true
  	  t.belongs_to :pitch, foreign_key: true
      t.timestamps
    end
    create_table :user_media do |t|
      t.belongs_to :user, foreign_key: true
  	  t.belongs_to :task_medium, foreign_key: true
      t.timestamps
    end
    create_table :user_pitches do |t|
      t.belongs_to :user, foreign_key: true
  	  t.belongs_to :pitch, foreign_key: true
      t.timestamps
    end
  end
end
