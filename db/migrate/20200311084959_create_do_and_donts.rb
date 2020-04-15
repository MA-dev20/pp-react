class CreateDoAndDonts < ActiveRecord::Migration[5.2]
  def change
    create_table :do_and_donts do |t|
      t.belongs_to :company, foreign_key: true
      t.belongs_to :department, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.string :does
      t.string :donts

      t.timestamps
    end
  end
end
