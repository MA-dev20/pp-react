class AddUserRelations < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :color_hex, :string
    create_table :company_users do |t|
      t.belongs_to :company, foreign_key: true
  	  t.belongs_to :user, foreign_key: true
      t.string :role, default: 'user'
      t.timestamps
    end
    create_table :department_users do |t|
      t.belongs_to :department, foreign_key: true
  	  t.belongs_to :user, foreign_key: true
      t.timestamps
    end

    change_table :users do |t|
      t.remove :company_id
      t.remove :department_id
      t.remove :role
    end


    change_table :task_media do |t|
      t.belongs_to :company, foreign_key: true
      t.belongs_to :department, foreign_key: true
      t.belongs_to :team, foreign_key: true
      t.belongs_to :user, foreign_key: true
    end

    change_table :catchwords do |t|
      t.belongs_to :user, foreign_key: true
    end
  end
end
