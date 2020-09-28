class CreateTeasers < ActiveRecord::Migration[5.2]
  def change
    create_table :teasers do |t|
      t.string :password
      t.string :fname
      t.string :lname
      t.string :logo
      t.integer :color1, array: true, default: [69, 177, 255]
      t.integer :color2, array: true, default: [29, 218, 175]
      t.string :color_hex
      t.timestamps
    end
  end
end
