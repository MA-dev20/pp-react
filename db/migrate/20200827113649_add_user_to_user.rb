class AddUserToUser < ActiveRecord::Migration[5.2]
  def change
    create_table :user_users do |t|
      t.belongs_to :user
      t.belongs_to :company
      t.integer :userID
    end
  end
end
