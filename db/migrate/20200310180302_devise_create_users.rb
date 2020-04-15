class DeviseCreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
	  t.belongs_to :company, foreign_key: true
	  t.belongs_to :department, foreign_key: true
	  t.string :fname, :lname, :avatar, :street, :city, :phone, :position
	  t.string :bo_role, default: 'none'
	  t.boolean :coach, default: false
	  t.string :role, default: 'user'
	  t.integer :zipcode
	  t.integer :ges_rating, default: 0
	  t.integer :ges_change, default: 0
	  
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
  end
end
