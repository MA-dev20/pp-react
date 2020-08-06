class AddUsersToObjection < ActiveRecord::Migration[5.2]
  def change
    change_table :objections do |t|
      t.belongs_to :department
      t.belongs_to :team
      t.belongs_to :user
    end
  end
end
